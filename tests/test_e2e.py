#
# Copyright Elasticsearch B.V. and/or licensed to Elasticsearch B.V. under one
# or more contributor license agreements. Licensed under the Elastic License 2.0;
# you may not use this file except in compliance with the Elastic License 2.0.
#

from contextlib import asynccontextmanager
import aiofiles
import aiohttp
import asyncio
import logging
import os
import subprocess
import pytest

ROOT = "http://localhost:8090"
EXTRACT_TEXT_URL = f"{ROOT}/extract_text/"
CHUNK_SIZE = 64 * 1024
FIPS_MODE = os.environ.get("FIPS_MODE", "false").lower() == "true"

logger = logging.getLogger("extraction-service")
logging.basicConfig(level=logging.INFO)

# for streaming file tests


async def filesender(filepath):
    async with aiofiles.open(filepath, "rb") as f:
        chunk = await f.read(CHUNK_SIZE)
        while chunk:
            yield chunk
            chunk = await f.read(CHUNK_SIZE)


@asynccontextmanager
async def logs_on_error():
    try:
        yield
    finally:
        log_dir = "/var/log/"
        target_dir = "tests/log"
        docker_cp = "docker cp extraction-service"

        os.makedirs(target_dir, exist_ok=True)

        # copy over all logs files
        for log_file in (
            "openresty.log",
            "tika.log",
        ):
            cmd = f"docker cp extraction-service:{log_dir}/{log_file} {target_dir}/{log_file}"
            os.system(cmd)


@logs_on_error()
@pytest.mark.asyncio
async def test_service_running():
    async with aiohttp.ClientSession() as session:
        async with session.get(ROOT) as resp:
            logger.info((await resp.text()).strip())
            assert resp.status == 200


@logs_on_error()
@pytest.mark.asyncio
@pytest.mark.parametrize(
    "file_name, expected_parser",
    [
        ("sample.pdf", "org.apache.tika.parser.pdf.PDFParser"),
        ("sample.rtf", "org.apache.tika.parser.microsoft.rtf.RTFParser"),
        ("sample.pptx", "org.apache.tika.parser.microsoft.ooxml.OOXMLParser"),
        ("sample.docx", "org.apache.tika.parser.microsoft.ooxml.OOXMLParser"),
        ("xfa_sample.pdf", "org.apache.tika.parser.pdf.PDFParser"),
    ],
)
async def test_extraction_parsed_correctly(file_name, expected_parser):
    async with aiohttp.ClientSession() as session:
        async with session.put(
            f"{EXTRACT_TEXT_URL}?local_file_path=/app/files/{file_name}"
        ) as resp:
            assert resp.status == 200
            result = await resp.json()
            assert result["_meta"]["X-ELASTIC:service"] == "tika"
            assert expected_parser in result["_meta"]["X-ELASTIC:TIKA:parsed_by"]

    async with aiohttp.ClientSession() as session:
        filepath = os.path.abspath(f"./tests/samples/{file_name}")
        async with session.put(EXTRACT_TEXT_URL, data=filesender(filepath)) as resp:
            assert resp.status == 200
            result = await resp.json()
            assert result["_meta"]["X-ELASTIC:service"] == "tika"
            assert expected_parser in result["_meta"]["X-ELASTIC:TIKA:parsed_by"]


@logs_on_error()
@pytest.mark.asyncio
async def test_extraction_with_corrupt_file_returns_422():
    file_name = "corrupt_sample.ppt"

    async with aiohttp.ClientSession() as session:
        async with session.put(
            f"{EXTRACT_TEXT_URL}?local_file_path=/app/files/{file_name}"
        ) as resp:
            assert resp.status == 422
            result = await resp.json(content_type=None)
            assert result["_meta"]["X-ELASTIC:service"] == "tika"
            assert (
                result["message"]
                == "Tikaserver could not process file. File may be corrupt or encrypted."
            )

    async with aiohttp.ClientSession() as session:
        filepath = os.path.abspath(f"./tests/samples/{file_name}")
        async with session.put(EXTRACT_TEXT_URL, data=filesender(filepath)) as resp:
            assert resp.status == 422
            result = await resp.json(content_type=None)
            assert result["_meta"]["X-ELASTIC:service"] == "tika"
            assert (
                result["message"]
                == "Tikaserver could not process file. File may be corrupt or encrypted."
            )


@pytest.mark.skipif(
    not FIPS_MODE, reason="FIPS mode tests only run when FIPS_MODE=true"
)
@pytest.mark.asyncio
async def test_fips_mode_enabled():
    """Verify that FIPS mode is properly configured when running FIPS image."""
    container_name = "extraction-service-fips" if FIPS_MODE else "extraction-service"

    result = subprocess.run(
        ["docker", "logs", container_name], capture_output=True, text=True
    )
    logs = result.stdout + result.stderr

    # Verify FIPS mode is reported as enabled in startup logs
    assert "FIPS_MODE: true" in logs, "FIPS_MODE should be true in container logs"
    assert "TIKA_CLASSPATH:" in logs, "TIKA_CLASSPATH should be set in container logs"
    assert "bc-fips.jar" in logs, "BouncyCastle FIPS JAR should be in classpath"

    # Verify service is still functional in FIPS mode
    async with aiohttp.ClientSession() as session:
        async with session.get(ROOT) as resp:
            assert resp.status == 200

    # Test extraction still works in FIPS mode
    file_name = "sample.pdf"
    async with aiohttp.ClientSession() as session:
        async with session.put(
            f"{EXTRACT_TEXT_URL}?local_file_path=/app/files/{file_name}"
        ) as resp:
            assert resp.status == 200
            result = await resp.json()
            assert result["_meta"]["X-ELASTIC:service"] == "tika"
            logger.info("FIPS mode extraction test passed")
