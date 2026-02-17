#!/usr/bin/env python3
"""
Script to create dummy nodal officers for specific areas/cities.

Creates NODAL_OFFICER users and NodalOfficerAssignment records for:
- Kota
- Jaipur
- Delhi
- Udaipur
"""

import asyncio
import sys
import os
from typing import List

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.user import User, Role, UserRole
from app.models.nodal_officer import (
    NodalOfficerAssignment,
    NodalOfficerStatus,
)
from app.utils.password import hash_password


NODAL_OFFICERS_TO_CREATE: List[dict] = [
    {
        "email": "kota.nodal@example.com",
        "full_name": "Sanjay Kumar (Kota Nodal Officer)",
        "phone": "+91-9100000001",
        "password": "Pass@1234",
        "area": "Kota",
        "location": "Kota, Rajasthan",
        "address": "Kota City, Rajasthan, India",
        "pincode": "324001",
        "region": "Rajasthan",
        "notes": "Dummy nodal officer for Kota region",
    },
    {
        "email": "jaipur.nodal@example.com",
        "full_name": "Anjali Gupta (Jaipur Nodal Officer)",
        "phone": "+91-9100000002",
        "password": "Pass@1234",
        "area": "Jaipur",
        "location": "Jaipur, Rajasthan",
        "address": "Jaipur City, Rajasthan, India",
        "pincode": "302001",
        "region": "Rajasthan",
        "notes": "Dummy nodal officer for Jaipur region",
    },
    {
        "email": "delhi.nodal@example.com",
        "full_name": "Rahul Khanna (Delhi Nodal Officer)",
        "phone": "+91-9100000003",
        "password": "Pass@1234",
        "area": "Delhi",
        "location": "New Delhi, Delhi",
        "address": "New Delhi, India",
        "pincode": "110001",
        "region": "Delhi NCR",
        "notes": "Dummy nodal officer for Delhi region",
    },
    {
        "email": "udaipur.nodal@example.com",
        "full_name": "Pooja Jain (Udaipur Nodal Officer)",
        "phone": "+91-9100000004",
        "password": "Pass@1234",
        "area": "Udaipur",
        "location": "Udaipur, Rajasthan",
        "address": "Udaipur City, Rajasthan, India",
        "pincode": "313001",
        "region": "Rajasthan",
        "notes": "Dummy nodal officer for Udaipur region",
    },
]


async def create_or_update_nodal_officer(data: dict) -> None:
    """Create or update a single nodal officer user + assignment."""
    # Check if user exists
    user = await User.find_one({"email": data["email"]})

    if not user:
        password_hash = hash_password(data["password"])
        user = User(
            email=data["email"],
            fullName=data["full_name"],
            passwordHash=password_hash,
            phone=data.get("phone"),
        )
        await user.insert()
        print(f"✅ Created nodal officer user: {user.email}")
    else:
        # Ensure password is set/updated
        user.passwordHash = hash_password(data["password"])
        user.fullName = data["full_name"]
        if data.get("phone"):
            user.phone = data["phone"]
        await user.save()
        print(f"ℹ️  Updated existing nodal officer user: {user.email}")

    # Ensure NODAL_OFFICER role exists
    existing_role = await Role.find_one(
        {"userId": str(user.id), "role": UserRole.NODAL_OFFICER}
    )
    if not existing_role:
        role = Role(userId=str(user.id), role=UserRole.NODAL_OFFICER)
        await role.insert()
        print(f"✅ Added NODAL_OFFICER role for: {user.email}")
    else:
        print(f"ℹ️  NODAL_OFFICER role already exists for: {user.email}")

    # Ensure NodalOfficerAssignment exists (one per officer_id+area ideally)
    assignment = await NodalOfficerAssignment.find_one({"officerId": str(user.id)})
    if not assignment:
        assignment = NodalOfficerAssignment(
            officerId=str(user.id),
            officer=user,
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            notes=data.get("notes"),
            status=NodalOfficerStatus.ACTIVE,
        )
        await assignment.insert()
        print(
            f"✅ Created NodalOfficerAssignment for {user.email} "
            f"in area {assignment.area} ({assignment.location})"
        )
    else:
        # Update existing assignment
        assignment.area = data["area"]
        assignment.location = data["location"]
        assignment.address = data.get("address")
        assignment.pincode = data.get("pincode")
        assignment.region = data.get("region")
        assignment.notes = data.get("notes")
        assignment.status = NodalOfficerStatus.ACTIVE
        await assignment.save()
        print(
            f"ℹ️  Updated NodalOfficerAssignment for {user.email} "
            f"in area {assignment.area} ({assignment.location})"
        )


async def main():
    print("\n" + "=" * 60)
    print("👥 Creating Dummy Nodal Officers for Kota, Jaipur, Delhi, Udaipur")
    print("=" * 60)

    await init_db()
    print("✅ Database initialized\n")

    for officer in NODAL_OFFICERS_TO_CREATE:
        await create_or_update_nodal_officer(officer)

    print("\n" + "=" * 60)
    print("✅ Dummy nodal officers created/updated successfully")
    print("=" * 60 + "\n")
    print("You can now log in with these dummy nodal officers, for example:")
    print("  Email: kota.nodal@example.com    Password: Pass@1234")
    print("  Email: jaipur.nodal@example.com  Password: Pass@1234")
    print("  Email: delhi.nodal@example.com   Password: Pass@1234")
    print("  Email: udaipur.nodal@example.com Password: Pass@1234")
    print("")


if __name__ == "__main__":
    asyncio.run(main())


