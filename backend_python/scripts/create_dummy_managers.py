#!/usr/bin/env python3
"""
Script to create dummy managers for specific areas/cities.

Creates MANAGER users and ManagerAssignment records for:
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
from app.models.manager import ManagerAssignment, ManagerAssignmentStatus
from app.utils.password import hash_password


MANAGERS_TO_CREATE: List[dict] = [
    {
        "email": "kota.manager@example.com",
        "full_name": "Rohan Sharma (Kota Manager)",
        "phone": "+91-9000000001",
        "password": "Pass@1234",
        "area": "Kota",
        "location": "Kota, Rajasthan",
        "address": "Kota City, Rajasthan, India",
        "pincode": "324001",
        "region": "Rajasthan",
        "notes": "Dummy manager for Kota region",
    },
    {
        "email": "jaipur.manager@example.com",
        "full_name": "Priya Singh (Jaipur Manager)",
        "phone": "+91-9000000002",
        "password": "Pass@1234",
        "area": "Jaipur",
        "location": "Jaipur, Rajasthan",
        "address": "Jaipur City, Rajasthan, India",
        "pincode": "302001",
        "region": "Rajasthan",
        "notes": "Dummy manager for Jaipur region",
    },
    {
        "email": "delhi.manager@example.com",
        "full_name": "Amit Verma (Delhi Manager)",
        "phone": "+91-9000000003",
        "password": "Pass@1234",
        "area": "Delhi",
        "location": "New Delhi, Delhi",
        "address": "New Delhi, India",
        "pincode": "110001",
        "region": "Delhi NCR",
        "notes": "Dummy manager for Delhi region",
    },
    {
        "email": "udaipur.manager@example.com",
        "full_name": "Neha Mehta (Udaipur Manager)",
        "phone": "+91-9000000004",
        "password": "Pass@1234",
        "area": "Udaipur",
        "location": "Udaipur, Rajasthan",
        "address": "Udaipur City, Rajasthan, India",
        "pincode": "313001",
        "region": "Rajasthan",
        "notes": "Dummy manager for Udaipur region",
    },
]


async def create_or_update_manager(data: dict) -> None:
    """Create or update a single manager user + assignment."""
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
        print(f"✅ Created manager user: {user.email}")
    else:
        # Ensure password is set/updated
        user.passwordHash = hash_password(data["password"])
        user.fullName = data["full_name"]
        if data.get("phone"):
            user.phone = data["phone"]
        await user.save()
        print(f"ℹ️  Updated existing manager user: {user.email}")

    # Ensure MANAGER role exists
    existing_role = await Role.find_one(
        {"userId": str(user.id), "role": UserRole.MANAGER}
    )
    if not existing_role:
        role = Role(userId=str(user.id), role=UserRole.MANAGER)
        await role.insert()
        print(f"✅ Added MANAGER role for: {user.email}")
    else:
        print(f"ℹ️  MANAGER role already exists for: {user.email}")

    # Ensure ManagerAssignment exists (unique per manager_id)
    assignment = await ManagerAssignment.find_one({"managerId": str(user.id)})
    if not assignment:
        assignment = ManagerAssignment(
            managerId=str(user.id),
            manager=user,
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            notes=data.get("notes"),
            status=ManagerAssignmentStatus.ACTIVE,
        )
        await assignment.insert()
        print(
            f"✅ Created ManagerAssignment for {user.email} "
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
        assignment.status = ManagerAssignmentStatus.ACTIVE
        await assignment.save()
        print(
            f"ℹ️  Updated ManagerAssignment for {user.email} "
            f"in area {assignment.area} ({assignment.location})"
        )


async def main():
    print("\n" + "=" * 60)
    print("👥 Creating Dummy Managers for Kota, Jaipur, Delhi, Udaipur")
    print("=" * 60)

    await init_db()
    print("✅ Database initialized\n")

    for mgr in MANAGERS_TO_CREATE:
        await create_or_update_manager(mgr)

    print("\n" + "=" * 60)
    print("✅ Dummy managers created/updated successfully")
    print("=" * 60 + "\n")
    print("You can now log in with these dummy managers, e.g.:")
    print("  Email: kota.manager@example.com   Password: Pass@1234")
    print("  Email: jaipur.manager@example.com Password: Pass@1234")
    print("  Email: delhi.manager@example.com  Password: Pass@1234")
    print("  Email: udaipur.manager@example.com Password: Pass@1234")
    print("")


if __name__ == "__main__":
    asyncio.run(main())


