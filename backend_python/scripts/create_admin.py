#!/usr/bin/env python3
"""
Script to create an admin user
"""
import asyncio
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.database.connection import init_db
from app.models.user import User, Role, UserRole
from app.utils.password import hash_password


async def create_admin():
    """Create admin user if it doesn't exist"""
    # Initialize database
    await init_db()
    
    # Check if admin exists
    admin = await User.find_one({"email": "admin@example.com"})
    
    if not admin:
        # Create admin user
        password_hash = hash_password("Pass@1234")
        
        admin = User(
            email="admin@example.com",
            passwordHash=password_hash,
            fullName="System Admin",
        )
        await admin.insert()
        print(f"✅ Admin user created: {admin.email}")
    else:
        print(f"✅ Admin user already exists: {admin.email}")
        # Update password hash to use new bcrypt method
        password_hash = hash_password("Pass@1234")
        # Use the Python field name (password_hash)
        admin.password_hash = password_hash
        await admin.save()
        print(f"✅ Updated password hash to use new bcrypt method")
    
    # Check and create roles
    roles = await Role.find({"userId": str(admin.id)}).to_list()
    existing_roles = {role.role for role in roles}
    
    # Create ADMIN role if it doesn't exist
    if UserRole.ADMIN not in existing_roles:
        admin_role = Role(userId=str(admin.id), role=UserRole.ADMIN)
        await admin_role.insert()
        print(f"✅ Added ADMIN role")
    
    # Create MANAGER role if it doesn't exist
    if UserRole.MANAGER not in existing_roles:
        manager_role = Role(userId=str(admin.id), role=UserRole.MANAGER)
        await manager_role.insert()
        print(f"✅ Added MANAGER role")
    
    # Display final status
    final_roles = await Role.find({"userId": str(admin.id)}).to_list()
    role_names = [role.role.value for role in final_roles]
    print(f"")
    print(f"📋 Admin User Details:")
    print(f"   Email: admin@example.com")
    print(f"   Password: Pass@1234")
    print(f"   Roles: {', '.join(role_names)}")
    print(f"   User ID: {admin.id}")


if __name__ == "__main__":
    asyncio.run(create_admin())

