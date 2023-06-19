import aiohttp
import asyncio
import logging


ROOT = "http://localhost:8090"
logger = logging.getLogger("extraction-service")
logging.basicConfig(level=logging.INFO)


async def main():
    # pinging root
    logger.info(f"Calling {ROOT}")
    async with aiohttp.ClientSession() as session:
        async with session.get(ROOT) as resp:
            assert resp.status == 200
            logger.info(await resp.text())

    logger.info("OK")


if __name__ == "__main__":
    asyncio.run(main())
