"""
Logging configuration
"""
import sys
from loguru import logger


def setup_logger():
    """Setup application logger"""
    logger.remove()  # Remove default handler
    
    # Add console handler
    logger.add(
        sys.stdout,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="DEBUG",
        colorize=True,
    )
    
    # Add file handler for errors
    logger.add(
        "logs/error.log",
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
        level="ERROR",
        rotation="10 MB",
        retention="7 days",
        compression="zip",
    )
    
    # Add file handler for all logs
    logger.add(
        "logs/combined.log",
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
        level="INFO",
        rotation="10 MB",
        retention="7 days",
        compression="zip",
    )
    
    return logger

