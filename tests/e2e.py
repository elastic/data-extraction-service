from contextlib import asynccontextmanager
import aiohttp
import asyncio
import logging
import os


ROOT = "http://localhost:8090"
logger = logging.getLogger("extraction-service")
logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def logs_on_error():
    try:
        yield
    except Exception:
        log_dir = "/var/log/"
        target_dir = "log"
        docker_cp = "docker cp extraction-service"

        os.makedirs(target_dir, exist_ok=True)

        # copy over all logs files
        for log_file in (
            "openresty_errors.log",
            "openresty.log",
            "tika.log",
            "tikaserver.log",
        ):
            cmd = f"docker cp extraction-service:{log_dir}/{log_file} {target_dir}/{log_file}"
            os.system(cmd)

        logger.critical(f"test failed check logs in {log_dir}")
        raise


@logs_on_error()
async def main():
    # pinging root
    logger.info(f"Calling {ROOT}")
    async with aiohttp.ClientSession() as session:
        async with session.get(ROOT) as resp:
            logger.info((await resp.text()).strip())
            assert resp.status == 200

    logger.info("OK")

    # extracting a pdf
    url = f"{ROOT}/extract_local_file_text/"
    params = {'local_file_path': 'sample.pdf'}

    async with aiohttp.ClientSession() as session:
        async with session.put(url, json=params, headers={"Accept": "application/json"}) as resp:
            # XXX assert the result of the extraction
            logger.info(await resp.text())
            assert resp.status == 200

    logger.info("OK")


if __name__ == "__main__":
    asyncio.run(main())
