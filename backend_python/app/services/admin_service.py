"""
Admin service
"""
from typing import Optional, List
from datetime import datetime
from app.models.user import User, Role, UserRole
from app.models.service_listing import ServiceListing, ServiceStatus
from app.models.verification import VerificationAssignment
from app.models.booking import Booking
from app.models.manager import ManagerAssignment, ManagerAssignmentStatus
from app.models.nodal_officer import (
    NodalOfficerAssignment,
    NodalOfficerRecommendation,
    NodalOfficerStatus,
    RecommendationStatus,
)
from app.models.service_category import ServiceCategory
from app.models.form_field_config import FormFieldConfig, FieldType
from app.models.verification_checkpoint_config import (
    VerificationCheckpointConfig,
    CheckpointType,
)
from app.middleware.error_handler import HttpError
from app.utils.password import hash_password
from app.config.logger import setup_logger

logger = setup_logger()


class AdminService:
    """Admin operations"""
    
    @staticmethod
    async def dashboard() -> dict:
        """Get admin dashboard stats"""
        total_users = await User.find({}).count()
        total_services = await ServiceListing.find({}).count()
        total_bookings = await Booking.find({}).count()
        verification_pending = await ServiceListing.find(
            {"status": "PENDING"}
        ).count()
        
        return {
            "totalUsers": total_users,
            "totalServices": total_services,
            "totalBookings": total_bookings,
            "verificationPending": verification_pending,
        }
    
    @staticmethod
    async def list_users() -> List[dict]:
        """List all users"""
        users = await User.find({}).to_list()
        result = []
        for user in users:
            roles = await Role.find({"userId": str(user.id)}).to_list()
            user_dict = user.model_dump(mode="json", by_alias=True)
            result.append({
                **user_dict,
                "roles": [{"role": role.role.value} for role in roles],
            })
        return result
    
    @staticmethod
    async def list_services() -> List[dict]:
        """List all services"""
        services = await ServiceListing.find({}).to_list()
        result = []
        for service in services:
            assigned_manager = None
            if service.assigned_manager_id:
                try:
                    assigned_manager = await User.find_one({"_id": service.assigned_manager_id})
                except:
                    try:
                        from bson import ObjectId
                        assigned_manager = await User.find_one({"_id": ObjectId(service.assigned_manager_id)})
                    except:
                        pass
            
            # Manual conversion to avoid _id serialization issues
            service_dict = {
                "id": str(service.id),
                "ownerId": str(service.owner_id) if service.owner_id else None,
                "assignedManagerId": str(service.assigned_manager_id) if service.assigned_manager_id else None,
                "assignedNodalOfficerId": str(service.assigned_nodal_officer_id) if service.assigned_nodal_officer_id else None,
                "title": service.title,
                "description": service.description,
                "location": service.location,
                "address": service.address,
                "pincode": service.pincode,
                "eventTypes": service.event_types,
                "propertyType": service.property_type,
                "capacity": service.capacity,
                "amenities": service.amenities,
                "photos": service.photos or [],
                "price": service.price,
                "status": service.status.value if hasattr(service.status, "value") else str(service.status),
                "submittedAt": service.submitted_at.isoformat() if service.submitted_at else None,
                "publishedAt": service.published_at.isoformat() if service.published_at else None,
            }
            
            manager_dict = None
            if assigned_manager:
                manager_dict = {
                    "id": str(assigned_manager.id),
                    "email": assigned_manager.email,
                    "fullName": assigned_manager.full_name,
                    "phone": assigned_manager.phone,
                }
            
            result.append({
                **service_dict,
                "assignedManager": manager_dict,
            })
        return result
    
    @staticmethod
    async def list_verifications() -> List[dict]:
        """List all verification assignments"""
        assignments = await VerificationAssignment.find({}).to_list()
        result = []
        for assignment in assignments:
            service = await ServiceListing.get(assignment.service_id)
            result.append({
                **assignment.dict(),
                "service": service.dict() if service else None,
            })
        return result
    
    @staticmethod
    async def create_manager(
        data: dict,
        assigned_by: Optional[str] = None,
    ) -> dict:
        """Create a new manager"""
        existing = await User.find_one({"email": data["email"]})
        if existing:
            raise HttpError(409, "Email already registered")
        
        password_hash = hash_password(data["password"])
        
        # Create user
        user = User(
            email=data["email"],
            fullName=data["fullName"],
            passwordHash=password_hash,
            phone=data.get("phone"),
        )
        await user.insert()
        
        # Create MANAGER role
        role = Role(userId=str(user.id), role=UserRole.MANAGER)
        await role.insert()
        
        # Create manager assignment
        assignment = ManagerAssignment(
            managerId=str(user.id),
            manager=user,  # Set the Link field
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            notes=data.get("notes"),
            assignedBy=assigned_by,
            status=ManagerAssignmentStatus.ACTIVE,
        )
        await assignment.insert()
        
        # Return user with roles and assignment
        roles = await Role.find({"userId": str(user.id)}).to_list()
        assignment_dict = assignment.model_dump(mode="json", by_alias=True)
        return {
            **user.model_dump(mode="json", by_alias=True),
            "roles": [{"role": role.role.value} for role in roles],
            "managerAssignment": assignment_dict,
        }
    
    @staticmethod
    async def update_manager(
        manager_id: str,
        data: dict,
    ) -> dict:
        """Update a manager"""
        user = await User.get(manager_id)
        if not user:
            raise HttpError(404, "Manager not found")
        
        # Update user fields
        if "fullName" in data:
            user.fullName = data["fullName"]
        if "phone" in data:
            user.phone = data.get("phone")
        if "password" in data and data["password"]:
            user.passwordHash = hash_password(data["password"])
        
        await user.save()
        
        # Update manager assignment if provided
        assignment = await ManagerAssignment.find_one({"managerId": manager_id})
        if assignment:
            if "area" in data:
                assignment.area = data["area"]
            if "location" in data:
                assignment.location = data["location"]
            if "address" in data:
                assignment.address = data.get("address")
            if "pincode" in data:
                assignment.pincode = data.get("pincode")
            if "region" in data:
                assignment.region = data.get("region")
            if "notes" in data:
                assignment.notes = data.get("notes")
            assignment.updated_at = datetime.utcnow()
            await assignment.save()
        
        # Return updated user with roles
        roles = await Role.find({"userId": manager_id}).to_list()
        assignment_dict = assignment.model_dump(mode="json", by_alias=True) if assignment else None
        return {
            **user.model_dump(mode="json", by_alias=True),
            "roles": [{"role": role.role.value} for role in roles],
            "managerAssignment": assignment_dict,
        }
    
    @staticmethod
    async def delete_manager(manager_id: str) -> None:
        """Delete a manager"""
        user = await User.get(manager_id)
        if not user:
            raise HttpError(404, "Manager not found")
        
        # Delete manager assignment
        assignment = await ManagerAssignment.find_one({"managerId": manager_id})
        if assignment:
            await assignment.delete()
        
        # Delete roles
        roles = await Role.find({"userId": manager_id}).to_list()
        for role in roles:
            await role.delete()
        
        # Delete user
        await user.delete()
    
    @staticmethod
    async def assign_manager(
        service_id: str,
        manager_id: str,
    ) -> dict:
        """Assign a manager to a service"""
        service = await ServiceListing.get(service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        manager = await User.get(manager_id)
        if not manager:
            raise HttpError(404, "Manager not found")
        
        # Check manager role
        roles = await Role.find(Role.user_id == manager_id).to_list()
        has_manager_role = any(role.role == UserRole.MANAGER for role in roles)
        if not has_manager_role:
            raise HttpError(400, "User does not have MANAGER role")
        
        service.assigned_manager_id = manager_id
        await service.save()
        
        assigned_manager = await User.get(manager_id)
        roles = await Role.find(Role.user_id == manager_id).to_list()
        
        return {
            **service.dict(),
            "assignedManager": {
                **assigned_manager.dict(),
                "roles": [{"role": role.role.value} for role in roles],
            } if assigned_manager else None,
        }
    
    @staticmethod
    async def create_nodal_officer(
        data: dict,
        assigned_by: Optional[str] = None,
    ) -> dict:
        """Create a new nodal officer"""
        existing = await User.find_one({"email": data["email"]})
        if existing:
            raise HttpError(409, "Email already registered")
        
        password_hash = hash_password(data["password"])
        
        # Create user
        user = User(
            email=data["email"],
            fullName=data["fullName"],
            passwordHash=password_hash,
            phone=data.get("phone"),
        )
        await user.insert()
        
        # Create NODAL_OFFICER role
        role = Role(userId=str(user.id), role=UserRole.NODAL_OFFICER)
        await role.insert()
        
        # Create assignment
        assignment = NodalOfficerAssignment(
            officerId=str(user.id),
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            notes=data.get("notes"),
            assignedBy=assigned_by,
            status=NodalOfficerStatus.ACTIVE,
        )
        await assignment.insert()
        
        return user.dict()
    
    @staticmethod
    async def list_nodal_officers(
        filters: Optional[dict] = None,
    ) -> List[dict]:
        """List nodal officers"""
        where_clause = {"status": NodalOfficerStatus.ACTIVE}
        
        if filters:
            if filters.get("pincode"):
                where_clause["pincode"] = filters["pincode"]
        
        officers = await NodalOfficerAssignment.find(where_clause).to_list()
        
        # Filter by location/area if provided
        if filters:
            if filters.get("location"):
                officers = [
                    o for o in officers
                    if filters["location"].lower() in o.location.lower()
                ]
            if filters.get("area"):
                officers = [
                    o for o in officers
                    if filters["area"].lower() in o.area.lower()
                ]
        
        result = []
        for officer in officers:
            try:
                officer_user = await User.get(officer.officer_id)
                roles = await Role.find({"userId": str(officer.officer_id)}).to_list()
                officer_dict = officer.model_dump(mode="json", by_alias=True)
                officer_user_dict = None
                if officer_user:
                    officer_user_dict = {
                        **officer_user.model_dump(mode="json", by_alias=True),
                        "roles": [{"role": role.role.value} for role in roles],
                    }
                result.append({
                    **officer_dict,
                    "officer": officer_user_dict,
                })
            except Exception as e:
                logger.error(f"Error processing nodal officer {officer.officer_id}: {e}", exc_info=True)
                # Continue with officer data even if user lookup fails
                officer_dict = officer.model_dump(mode="json", by_alias=True)
                result.append({
                    **officer_dict,
                    "officer": None,
                })
        
        return result
    
    @staticmethod
    async def assign_officer_to_area(
        officer_id: str,
        data: dict,
        assigned_by: Optional[str] = None,
    ) -> dict:
        """Assign an officer to an area"""
        officer = await User.get(officer_id)
        if not officer:
            raise HttpError(404, "Officer not found")
        
        # Check officer role
        roles = await Role.find(Role.user_id == officer_id).to_list()
        has_role = any(role.role == UserRole.NODAL_OFFICER for role in roles)
        if not has_role:
            raise HttpError(400, "User does not have NODAL_OFFICER role")
        
        assignment = NodalOfficerAssignment(
            officerId=officer_id,
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            notes=data.get("notes"),
            assignedBy=assigned_by,
            status=NodalOfficerStatus.ACTIVE,
        )
        await assignment.insert()
        
        officer_user = await User.get(officer_id)
        roles = await Role.find(Role.user_id == officer_id).to_list()
        
        return {
            **assignment.dict(),
            "officer": {
                **officer_user.dict(),
                "roles": [{"role": role.role.value} for role in roles],
            } if officer_user else None,
        }
    
    @staticmethod
    async def list_recommendations(
        status: Optional[str] = None,
    ) -> List[dict]:
        """List nodal officer recommendations"""
        where_clause = {}
        if status:
            where_clause["status"] = RecommendationStatus(status)
        
        recommendations = await NodalOfficerRecommendation.find(where_clause).to_list()
        
        result = []
        for rec in recommendations:
            try:
                officer = await User.get(rec.officer_id) if rec.officer_id else None
                manager = await User.get(rec.manager_id) if rec.manager_id else None
                
                rec_dict = rec.model_dump(mode="json", by_alias=True)
                officer_dict = None
                manager_dict = None
                
                if officer:
                    officer_dict = officer.model_dump(mode="json", by_alias=True)
                if manager:
                    manager_dict = manager.model_dump(mode="json", by_alias=True)
                
                result.append({
                    **rec_dict,
                    "officer": officer_dict,
                    "manager": manager_dict,
                })
            except Exception as e:
                logger.error(f"Error processing recommendation {rec.id}: {e}", exc_info=True)
                # Continue with recommendation data even if user lookup fails
                rec_dict = rec.model_dump(mode="json", by_alias=True)
                result.append({
                    **rec_dict,
                    "officer": None,
                    "manager": None,
                })
        
        return result
    
    @staticmethod
    async def approve_recommendation(
        recommendation_id: str,
        reviewed_by: str,
    ) -> dict:
        """Approve a recommendation"""
        recommendation = await NodalOfficerRecommendation.get(recommendation_id)
        if not recommendation:
            raise HttpError(404, "Recommendation not found")
        
        if recommendation.status != RecommendationStatus.PENDING:
            raise HttpError(400, "Recommendation already processed")
        
        final_officer_id = recommendation.officer_id
        
        # Create user if new recommendation
        if not final_officer_id and recommendation.new_user_email and recommendation.new_user_full_name:
            existing = await User.find_one({"email": recommendation.new_user_email})
            if existing:
                raise HttpError(409, "User with this email already exists")
            
            # Generate temp password
            from datetime import datetime
            temp_password = f"Temp{int(datetime.utcnow().timestamp())}"
            password_hash = hash_password(temp_password)
            
            # Create user
            new_user = User(
                email=recommendation.new_user_email,
                fullName=recommendation.new_user_full_name,
                phone=recommendation.new_user_phone,
                passwordHash=password_hash,
            )
            await new_user.insert()
            
            # Create role
            role = Role(userId=str(new_user.id), role=UserRole.NODAL_OFFICER)
            await role.insert()
            
            final_officer_id = str(new_user.id)
            
            # Update recommendation
            recommendation.officer_id = final_officer_id
            await recommendation.save()
        
        if not final_officer_id:
            raise HttpError(400, "Invalid recommendation: no officer ID or new user details")
        
        # Update recommendation status
        recommendation.status = RecommendationStatus.APPROVED
        recommendation.reviewed_by = reviewed_by
        from datetime import datetime
        recommendation.reviewed_at = datetime.utcnow()
        await recommendation.save()
        
        # Create assignment
        existing_assignment = await NodalOfficerAssignment.find_one({
            "officerId": final_officer_id,
            "area": recommendation.area,
            "location": recommendation.location,
            "status": NodalOfficerStatus.ACTIVE,
        })
        
        if not existing_assignment:
            assignment = NodalOfficerAssignment(
                officerId=final_officer_id,
                area=recommendation.area,
                location=recommendation.location,
                address=recommendation.address,
                pincode=recommendation.pincode,
                region=recommendation.region,
                notes=recommendation.reason or recommendation.notes,
                assignedBy=reviewed_by,
                status=NodalOfficerStatus.ACTIVE,
            )
            await assignment.insert()
        
        # Return updated recommendation
        officer = await User.get(final_officer_id) if final_officer_id else None
        manager = await User.get(recommendation.manager_id) if recommendation.manager_id else None
        
        rec_dict = recommendation.model_dump(mode="json", by_alias=True)
        officer_dict = officer.model_dump(mode="json", by_alias=True) if officer else None
        manager_dict = manager.model_dump(mode="json", by_alias=True) if manager else None
        
        return {
            **rec_dict,
            "officer": officer_dict,
            "manager": manager_dict,
        }
    
    @staticmethod
    async def reject_recommendation(
        recommendation_id: str,
        reviewed_by: str,
        notes: Optional[str] = None,
    ) -> dict:
        """Reject a recommendation"""
        recommendation = await NodalOfficerRecommendation.get(recommendation_id)
        if not recommendation:
            raise HttpError(404, "Recommendation not found")
        
        if recommendation.status != RecommendationStatus.PENDING:
            raise HttpError(400, "Recommendation already processed")
        
        recommendation.status = RecommendationStatus.REJECTED
        recommendation.reviewed_by = reviewed_by
        from datetime import datetime
        recommendation.reviewed_at = datetime.utcnow()
        if notes:
            recommendation.notes = notes
        await recommendation.save()
        
        officer = await User.get(recommendation.officer_id) if recommendation.officer_id else None
        manager = await User.get(recommendation.manager_id) if recommendation.manager_id else None
        
        rec_dict = recommendation.model_dump(mode="json", by_alias=True)
        officer_dict = officer.model_dump(mode="json", by_alias=True) if officer else None
        manager_dict = manager.model_dump(mode="json", by_alias=True) if manager else None
        
        return {
            **rec_dict,
            "officer": officer_dict,
            "manager": manager_dict,
        }
    
    @staticmethod
    async def list_service_categories() -> List[dict]:
        """List all service categories"""
        categories = await ServiceCategory.find_all().to_list()
        categories.sort(key=lambda c: (c.display_order, c.name))
        return [c.dict() for c in categories]
    
    @staticmethod
    async def create_service_category(data: dict) -> ServiceCategory:
        """Create a service category"""
        existing = await ServiceCategory.find_one({"name": data["name"]})
        if existing:
            raise HttpError(409, "Service category with this name already exists")
        
        category = ServiceCategory(
            name=data["name"],
            description=data.get("description"),
            showInNavbar=data.get("showInNavbar", False),
            displayOrder=data.get("displayOrder", 0),
            isActive=data.get("isActive", True),
        )
        await category.insert()
        return category
    
    @staticmethod
    async def update_service_category(
        category_id: str,
        data: dict,
    ) -> ServiceCategory:
        """Update a service category"""
        category = await ServiceCategory.get(category_id)
        if not category:
            raise HttpError(404, "Service category not found")
        
        # Check name uniqueness if updating
        if data.get("name") and data["name"] != category.name:
            existing = await ServiceCategory.find_one(
                {"name": data["name"], "id": {"$ne": category_id}}
            )
            if existing:
                raise HttpError(409, "Service category with this name already exists")
        
        if "name" in data:
            category.name = data["name"]
        if "description" in data:
            category.description = data["description"]
        if "showInNavbar" in data:
            category.show_in_navbar = data["showInNavbar"]
        if "displayOrder" in data:
            category.display_order = data["displayOrder"]
        if "isActive" in data:
            category.is_active = data["isActive"]
        
        await category.save()
        return category
    
    @staticmethod
    async def delete_service_category(category_id: str):
        """Delete a service category"""
        category = await ServiceCategory.get(category_id)
        if not category:
            raise HttpError(404, "Service category not found")
        await category.delete()
    
    @staticmethod
    async def list_form_field_configs() -> List[dict]:
        """List all form field configurations"""
        fields = await FormFieldConfig.find_all().to_list()
        fields.sort(key=lambda f: (f.display_order, f.field_key))
        result = []
        for field in fields:
            field_dict = field.model_dump(mode="json", by_alias=True)
            field_dict["fieldType"] = field.field_type.value if hasattr(field.field_type, "value") else str(field.field_type)
            result.append(field_dict)
        return result
    
    @staticmethod
    async def get_form_field_config(field_id: str) -> dict:
        """Get a single form field configuration"""
        field = await FormFieldConfig.get(field_id)
        if not field:
            raise HttpError(404, "Form field configuration not found")
        field_dict = field.model_dump(mode="json", by_alias=True)
        field_dict["fieldType"] = field.field_type.value if hasattr(field.field_type, "value") else str(field.field_type)
        return field_dict
    
    @staticmethod
    async def create_form_field_config(data: dict) -> FormFieldConfig:
        """Create a form field configuration"""
        # Check if field_key already exists
        existing = await FormFieldConfig.find_one({"fieldKey": data["fieldKey"]})
        if existing:
            raise HttpError(409, "Form field configuration with this field key already exists")
        
        field = FormFieldConfig(
            fieldKey=data["fieldKey"],
            label=data["label"],
            fieldType=data["fieldType"],
            isRequired=data.get("isRequired", False),
            isEnabled=data.get("isEnabled", True),
            displayOrder=data.get("displayOrder", 0),
            validation=data.get("validation"),
            options=data.get("options"),
            placeholder=data.get("placeholder"),
            hint=data.get("hint"),
            step=data.get("step"),
        )
        await field.insert()
        return field
    
    @staticmethod
    async def update_form_field_config(field_id: str, data: dict) -> FormFieldConfig:
        """Update a form field configuration"""
        field = await FormFieldConfig.get(field_id)
        if not field:
            raise HttpError(404, "Form field configuration not found")
        
        # Check field_key uniqueness if updating
        if data.get("fieldKey") and data["fieldKey"] != field.field_key:
            existing = await FormFieldConfig.find_one(
                {"fieldKey": data["fieldKey"], "id": {"$ne": field_id}}
            )
            if existing:
                raise HttpError(409, "Form field configuration with this field key already exists")
        
        # Update fields
        if "fieldKey" in data:
            field.field_key = data["fieldKey"]
        if "label" in data:
            field.label = data["label"]
        if "fieldType" in data:
            field.field_type = FieldType(data["fieldType"]) if isinstance(data["fieldType"], str) else data["fieldType"]
        if "isRequired" in data:
            field.is_required = data["isRequired"]
        if "isEnabled" in data:
            field.is_enabled = data["isEnabled"]
        if "displayOrder" in data:
            field.display_order = data["displayOrder"]
        if "validation" in data:
            field.validation = data["validation"]
        if "options" in data:
            field.options = data["options"]
        if "placeholder" in data:
            field.placeholder = data["placeholder"]
        if "hint" in data:
            field.hint = data["hint"]
        if "step" in data:
            field.step = data["step"]
        
        await field.save()
        return field
    
    @staticmethod
    async def delete_form_field_config(field_id: str):
        """Delete a form field configuration"""
        field = await FormFieldConfig.get(field_id)
        if not field:
            raise HttpError(404, "Form field configuration not found")
        
        # Warn if deleting a required field (but allow it)
        if field.is_required:
            logger.warning(f"Deleting required field: {field.field_key}")
        
        await field.delete()
    
    @staticmethod
    async def get_active_form_field_configs() -> List[dict]:
        """Get active form field configurations for the submission form (public endpoint)"""
        fields = await FormFieldConfig.find({"isEnabled": True}).to_list()
        fields.sort(key=lambda f: (f.display_order, f.field_key))
        result = []
        for field in fields:
            field_dict = field.model_dump(mode="json", by_alias=True)
            field_dict["fieldType"] = field.field_type.value if hasattr(field.field_type, "value") else str(field.field_type)
            result.append(field_dict)
        return result
    
    @staticmethod
    async def list_verification_checkpoint_configs() -> List[dict]:
        """List all verification checkpoint configurations"""
        checkpoints = await VerificationCheckpointConfig.find_all().to_list()
        checkpoints.sort(key=lambda c: (c.display_order, c.checkpoint_key))
        result = []
        for checkpoint in checkpoints:
            checkpoint_dict = checkpoint.model_dump(mode="json", by_alias=True)
            checkpoint_dict["checkpointType"] = checkpoint.checkpoint_type.value if hasattr(checkpoint.checkpoint_type, "value") else str(checkpoint.checkpoint_type)
            result.append(checkpoint_dict)
        return result
    
    @staticmethod
    async def get_verification_checkpoint_config(checkpoint_id: str) -> dict:
        """Get a single verification checkpoint configuration"""
        checkpoint = await VerificationCheckpointConfig.get(checkpoint_id)
        if not checkpoint:
            raise HttpError(404, "Verification checkpoint configuration not found")
        checkpoint_dict = checkpoint.model_dump(mode="json", by_alias=True)
        checkpoint_dict["checkpointType"] = checkpoint.checkpoint_type.value if hasattr(checkpoint.checkpoint_type, "value") else str(checkpoint.checkpoint_type)
        return checkpoint_dict
    
    @staticmethod
    async def create_verification_checkpoint_config(data: dict) -> VerificationCheckpointConfig:
        """Create a verification checkpoint configuration"""
        # Check if checkpoint_key already exists
        existing = await VerificationCheckpointConfig.find_one({"checkpointKey": data["checkpointKey"]})
        if existing:
            raise HttpError(409, "Verification checkpoint configuration with this checkpoint key already exists")
        
        checkpoint = VerificationCheckpointConfig(
            checkpointKey=data["checkpointKey"],
            label=data["label"],
            checkpointType=data["checkpointType"],
            description=data.get("description"),
            isRequired=data.get("isRequired", True),
            isEnabled=data.get("isEnabled", True),
            displayOrder=data.get("displayOrder", 0),
            validation=data.get("validation"),
            options=data.get("options"),
            placeholder=data.get("placeholder"),
            hint=data.get("hint"),
            category=data.get("category"),
        )
        await checkpoint.insert()
        return checkpoint
    
    @staticmethod
    async def update_verification_checkpoint_config(checkpoint_id: str, data: dict) -> VerificationCheckpointConfig:
        """Update a verification checkpoint configuration"""
        checkpoint = await VerificationCheckpointConfig.get(checkpoint_id)
        if not checkpoint:
            raise HttpError(404, "Verification checkpoint configuration not found")
        
        # Check checkpoint_key uniqueness if updating
        if data.get("checkpointKey") and data["checkpointKey"] != checkpoint.checkpoint_key:
            existing = await VerificationCheckpointConfig.find_one(
                {"checkpointKey": data["checkpointKey"], "id": {"$ne": checkpoint_id}}
            )
            if existing:
                raise HttpError(409, "Verification checkpoint configuration with this checkpoint key already exists")
        
        # Update fields
        if "checkpointKey" in data:
            checkpoint.checkpoint_key = data["checkpointKey"]
        if "label" in data:
            checkpoint.label = data["label"]
        if "checkpointType" in data:
            checkpoint.checkpoint_type = CheckpointType(data["checkpointType"]) if isinstance(data["checkpointType"], str) else data["checkpointType"]
        if "description" in data:
            checkpoint.description = data["description"]
        if "isRequired" in data:
            checkpoint.is_required = data["isRequired"]
        if "isEnabled" in data:
            checkpoint.is_enabled = data["isEnabled"]
        if "displayOrder" in data:
            checkpoint.display_order = data["displayOrder"]
        if "validation" in data:
            checkpoint.validation = data["validation"]
        if "options" in data:
            checkpoint.options = data["options"]
        if "placeholder" in data:
            checkpoint.placeholder = data["placeholder"]
        if "hint" in data:
            checkpoint.hint = data["hint"]
        if "category" in data:
            checkpoint.category = data["category"]
        
        await checkpoint.save()
        return checkpoint
    
    @staticmethod
    async def delete_verification_checkpoint_config(checkpoint_id: str):
        """Delete a verification checkpoint configuration"""
        checkpoint = await VerificationCheckpointConfig.get(checkpoint_id)
        if not checkpoint:
            raise HttpError(404, "Verification checkpoint configuration not found")
        
        # Warn if deleting a required checkpoint (but allow it)
        if checkpoint.is_required:
            logger.warning(f"Deleting required checkpoint: {checkpoint.checkpoint_key}")
        
        await checkpoint.delete()
    
    @staticmethod
    async def get_active_verification_checkpoint_configs() -> List[dict]:
        """Get active verification checkpoint configurations for nodal officers (public endpoint)"""
        checkpoints = await VerificationCheckpointConfig.find({"isEnabled": True}).to_list()
        checkpoints.sort(key=lambda c: (c.display_order, c.checkpoint_key))
        result = []
        for checkpoint in checkpoints:
            checkpoint_dict = checkpoint.model_dump(mode="json", by_alias=True)
            checkpoint_dict["checkpointType"] = checkpoint.checkpoint_type.value if hasattr(checkpoint.checkpoint_type, "value") else str(checkpoint.checkpoint_type)
            result.append(checkpoint_dict)
        return result


