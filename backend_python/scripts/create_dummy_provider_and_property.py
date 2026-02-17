#!/usr/bin/env python3
"""
Script to create a dummy service provider and a dummy property (service listing).

Creates:
- A PROVIDER user
- ServiceProvider profile
- One ServiceListing owned by that provider
"""

import asyncio
import sys
import os
from typing import Optional

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.user import User, Role, UserRole
from app.models.service_listing import ServiceListing
from app.models.service_provider import ServiceProvider, ProviderStatus
from app.services.service_service import ServiceService
from app.utils.password import hash_password


PROVIDER_EMAIL = "jaipur.provider@example.com"
PROVIDER_PASSWORD = "Pass@1234"
PROVIDER_FULL_NAME = "Jaipur Events (Demo Provider)"
PROVIDER_PHONE = "+91-9200000001"


async def create_or_update_provider() -> User:
    """Create or update a provider user and provider profile."""
    user: Optional[User] = await User.find_one({"email": PROVIDER_EMAIL})

    if not user:
        password_hash = hash_password(PROVIDER_PASSWORD)
        user = User(
            email=PROVIDER_EMAIL,
            fullName=PROVIDER_FULL_NAME,
            passwordHash=password_hash,
            phone=PROVIDER_PHONE,
        )
        await user.insert()
        print(f"✅ Created provider user: {user.email}")
    else:
        # Use internal field names (password_hash, full_name) when updating
        user.password_hash = hash_password(PROVIDER_PASSWORD)
        user.full_name = PROVIDER_FULL_NAME
        user.phone = PROVIDER_PHONE
        await user.save()
        print(f"ℹ️  Updated existing provider user: {user.email}")

    # Ensure PROVIDER role exists
    existing_role = await Role.find_one(
        {"userId": str(user.id), "role": UserRole.PROVIDER}
    )
    if not existing_role:
        role = Role(userId=str(user.id), role=UserRole.PROVIDER)
        await role.insert()
        print(f"✅ Added PROVIDER role for: {user.email}")
    else:
        print(f"ℹ️  PROVIDER role already exists for: {user.email}")

    # Onboard provider profile (KYC/pricing) directly via ServiceProvider model
    provider = await ServiceProvider.find_one({"userId": str(user.id)})
    if provider:
        provider.kyc_document_url = "https://example.com/demo-kyc.pdf"
        provider.pricing_details = (
            "Standard wedding and event packages starting from ₹75,000."
        )
        provider.photos = [
            "https://dummyimage.com/800x400/4caf50/ffffff&text=Royal+Heritage+Banquet",
            "https://dummyimage.com/800x400/2196f3/ffffff&text=Grand+Ballroom",
        ]
        provider.status = ProviderStatus.PENDING
        await provider.save()
        print(f"ℹ️  Updated existing provider profile for: {user.email}")
    else:
        provider = ServiceProvider(
            userId=str(user.id),
            user=user,
            kycDocumentUrl="https://example.com/demo-kyc.pdf",
            pricingDetails=(
                "Standard wedding and event packages starting from ₹75,000."
            ),
            photos=[
                "https://dummyimage.com/800x400/4caf50/ffffff&text=Royal+Heritage+Banquet",
                "https://dummyimage.com/800x400/2196f3/ffffff&text=Grand+Ballroom",
            ],
            status=ProviderStatus.PENDING,
        )
        await provider.insert()
        print(f"✅ Created provider profile for: {user.email}")

    return user


async def create_dummy_property(owner: User) -> ServiceListing:
    """Create a dummy property (service listing) for the given provider."""
    title = "Royal Heritage Banquet, Jaipur"

    # Check if this property already exists for this owner
    existing = await ServiceListing.find_one(
        {"ownerId": str(owner.id), "title": title}
    )
    if existing:
        print(f"ℹ️  Service listing already exists: {title}")
        return existing

    data = {
        "title": title,
        "description": "A beautiful heritage banquet hall in Jaipur, perfect for weddings, receptions, and corporate events.",
        "location": "Jaipur, Rajasthan",
        "address": "Near Hawa Mahal, Jaipur, Rajasthan, India",
        "pincode": "302001",
        "eventTypes": "Wedding, Reception, Corporate Event",
        "propertyType": "Banquet Hall",
        "capacity": 300,
        "amenities": "Parking, AC, Stage, Catering, Sound System, Lighting",
        "photos": [
            "https://dummyimage.com/1200x600/673ab7/ffffff&text=Main+Hall",
            "https://dummyimage.com/1200x600/009688/ffffff&text=Outdoor+Lawn",
        ],
        "price": 75000.0,
    }

    service = await ServiceService.create_service(str(owner.id), data)
    print(
        f"✅ Created service listing '{service.title}' for provider {owner.email} "
        f"in location {service.location}"
    )
    return service


async def main():
    print("\n" + "=" * 60)
    print("🏨 Creating Dummy Service Provider and Property")
    print("=" * 60)

    await init_db()
    print("✅ Database initialized\n")

    provider_user = await create_or_update_provider()
    service = await create_dummy_property(provider_user)

    print("\n" + "=" * 60)
    print("✅ Dummy provider and property created successfully")
    print("=" * 60 + "\n")
    print("Provider login credentials:")
    print(f"  Email: {PROVIDER_EMAIL}")
    print(f"  Password: {PROVIDER_PASSWORD}")
    print("")
    print("Created property:")
    print(f"  Title: {service.title}")
    print(f"  Location: {service.location}")
    print(f"  Price: ₹{service.price}")
    print("")


if __name__ == "__main__":
    asyncio.run(main())


