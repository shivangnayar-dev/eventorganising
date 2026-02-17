"""
Database connection and initialization
"""
from motor.motor_asyncio import AsyncIOMotorClient
from beanie import init_beanie
from app.config.env import settings
from app.config.logger import setup_logger
from app.models.user import User, Role
from app.models.service_provider import ServiceProvider
from app.models.service_listing import ServiceListing
from app.models.verification import VerificationAssignment
from app.models.booking import Booking, Payment
from app.models.review import Review
from app.models.nodal_officer import NodalOfficerAssignment, NodalOfficerRecommendation
from app.models.manager import ManagerAssignment
from app.models.service_category import ServiceCategory
from app.models.refresh_token import RefreshToken
from app.models.form_field_config import FormFieldConfig
from app.models.verification_checkpoint_config import VerificationCheckpointConfig

logger = setup_logger()
db = None
client = None


async def init_db():
    """Initialize database connection"""
    global db, client
    
    try:
        client = AsyncIOMotorClient(settings.database_url)
        db = client.get_default_database()
        
        # Initialize Beanie with all document models
        # Note: We skip index creation to avoid conflicts with existing Prisma indexes
        try:
            await init_beanie(
                database=db,
                document_models=[
                    User,
                    Role,
                    ServiceProvider,
                    ServiceListing,
                    VerificationAssignment,
                    Booking,
                    Payment,
                    Review,
                    NodalOfficerAssignment,
                    NodalOfficerRecommendation,
                    ManagerAssignment,
                    ServiceCategory,
                    RefreshToken,
                    FormFieldConfig,
                    VerificationCheckpointConfig,
                ],
            )
            logger.info("Database initialized successfully")
        except Exception as beanie_error:
            # If Beanie initialization fails due to index conflicts, 
            # we can still use the database connection
            error_str = str(beanie_error)
            if ("Index" in error_str and "already exists" in error_str) or \
               ("IndexOptionsConflict" in error_str) or \
               ("code" in str(beanie_error) and "85" in str(beanie_error)):
                logger.warning(f"Index conflict detected (expected with existing Prisma indexes): {error_str}")
                logger.info("Database connection established (indexes managed by Prisma)")
                # Continue - the database connection is still valid
            else:
                logger.error(f"Failed to initialize Beanie: {beanie_error}")
                raise
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")
        raise


async def close_db():
    """Close database connection"""
    global client
    if client:
        client.close()
        logger.info("Database connection closed")

