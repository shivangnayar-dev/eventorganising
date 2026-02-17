"""
Service listing service
"""
from typing import Optional, List, Any
from datetime import datetime
from app.models.service_listing import ServiceListing, ServiceStatus
from app.models.user import User, Role, UserRole
from app.models.service_provider import ServiceProvider, ProviderStatus
from app.models.verification import VerificationAssignment, VerificationStatus
from app.models.nodal_officer import (
    NodalOfficerAssignment,
    NodalOfficerRecommendation,
    NodalOfficerStatus,
    RecommendationStatus,
)
from app.models.manager import ManagerAssignment
from app.models.service_category import ServiceCategory
from app.middleware.error_handler import HttpError
from app.utils.jwt import sign_token
from app.config.env import settings
from app.config.logger import setup_logger

logger = setup_logger()


class ServiceService:
    """Service listing operations"""
    
    @staticmethod
    async def create_service(
        owner_id: str,
        data: dict,
    ) -> ServiceListing:
        """Create a new service listing"""
        service = ServiceListing(
            ownerId=owner_id,
            title=data["title"],
            description=data["description"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            eventTypes=data.get("eventTypes"),
            propertyType=data.get("propertyType"),
            capacity=data.get("capacity"),
            amenities=data.get("amenities"),
            photos=data.get("photos"),
            price=data["price"],
            status=ServiceStatus.PENDING,
        )
        await service.insert()
        return service
    
    @staticmethod
    async def list_user_services(owner_id: str) -> List[ServiceListing]:
        """List services owned by a user"""
        services = await ServiceListing.find(
            ServiceListing.owner_id == owner_id
        ).to_list()
        return services
    
    @staticmethod
    async def list_nodal_officer_services(officer_id: str) -> List[ServiceListing]:
        """List services assigned to a nodal officer"""
        services = await ServiceListing.find(
            ServiceListing.assigned_nodal_officer_id == officer_id
        ).to_list()
        return services
    
    @staticmethod
    async def list_pending() -> List[ServiceListing]:
        """List pending services"""
        # Use dictionary query for Beanie
        services = await ServiceListing.find(
            {"status": "PENDING"}
        ).to_list()
        return services
    
    @staticmethod
    async def list_published() -> List[ServiceListing]:
        """List published services"""
        # Use dictionary query for Beanie
        services = await ServiceListing.find(
            {"status": "PUBLISHED"}
        ).to_list()
        return services
    
    @staticmethod
    async def list_managed_services(manager_id: str) -> List[dict]:
        """List services managed by a manager"""
        services = await ServiceListing.find(
            {"assignedManagerId": manager_id}
        ).to_list()
        
        result = []
        for service in services:
            owner = await User.get(service.owner_id) if service.owner_id else None
            assigned_manager = await User.get(service.assigned_manager_id) if service.assigned_manager_id else None
            assigned_nodal_officer = await User.get(service.assigned_nodal_officer_id) if service.assigned_nodal_officer_id else None
            
            result.append({
                **service.dict(),
                "owner": {
                    "id": str(owner.id) if owner else None,
                    "fullName": owner.full_name if owner else None,
                    "email": owner.email if owner else None,
                } if owner else None,
                "assignedManager": assigned_manager.dict() if assigned_manager else None,
                "assignedNodalOfficer": assigned_nodal_officer.dict() if assigned_nodal_officer else None,
            })
        
        return result
    
    @staticmethod
    async def assign_nodal_officer(
        manager_id: str,
        service_id: str,
        nodal_officer_id: str,
    ) -> dict:
        """Assign a nodal officer to a service"""
        service = await ServiceListing.get(service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        # Verify nodal officer exists and is active
        officer_assignment = await NodalOfficerAssignment.find_one(
            {"officerId": nodal_officer_id, "status": "ACTIVE"}
        )
        
        if not officer_assignment:
            raise HttpError(404, "Nodal officer not found or not active")
        
        # Update service
        service.status = ServiceStatus.ASSIGNED
        service.assigned_nodal_officer_id = nodal_officer_id
        await service.save()
        
        # Send notification
        await ServiceService._send_nodal_officer_notification(
            officer_assignment.officer_id,
            service,
        )
        
        # Fetch updated service with relations
        assigned_nodal_officer = await User.get(nodal_officer_id)
        
        return {
            "service": service.dict(),
            "nodalOfficer": assigned_nodal_officer.dict() if assigned_nodal_officer else None,
        }
    
    @staticmethod
    async def _send_nodal_officer_notification(
        officer_id: str,
        service: ServiceListing,
    ):
        """Send notification to nodal officer"""
        officer = await User.get(officer_id)
        if not officer:
            return
        
        # Generate activation token
        activation_token = sign_token(
            {"userId": str(officer.id), "type": "password_setup"},
            expires_in="7d",
        )
        
        frontend_url = settings.frontend_url or "http://localhost"
        activation_link = f"{frontend_url}/auth/setup-password?token={activation_token}"
        
        logger.info("Nodal Officer Assignment Notification", {
            "officerEmail": officer.email,
            "officerPhone": officer.phone,
            "serviceTitle": service.title,
            "serviceLocation": service.location,
            "activationLink": activation_link,
        })
        
        # TODO: Send email notification
        # from app.utils.email import send_nodal_officer_assignment_email
        # await send_nodal_officer_assignment_email(...)
    
    @staticmethod
    async def assign_agents(
        manager_id: str,
        service_id: str,
        agent_ids: List[str],
        nodal_officer_id: Optional[str] = None,
    ) -> dict:
        """Assign verification agents to a service"""
        service = await ServiceListing.get(service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        # Find available officers
        available_officers = await ServiceService.find_nodal_officers_by_location(
            service.location,
            service.pincode,
        )
        
        final_nodal_officer_id = nodal_officer_id
        
        # Auto-assign if no officer provided
        if not final_nodal_officer_id and available_officers:
            final_nodal_officer_id = available_officers[0]["officerId"]
        
        # Verify officer is in area
        if final_nodal_officer_id:
            officer_exists = any(
                o["officerId"] == final_nodal_officer_id for o in available_officers
            )
            if not officer_exists:
                raise HttpError(
                    400,
                    "Selected nodal officer is not assigned to this service area",
                )
        
        # Update service status
        service.status = ServiceStatus.ASSIGNED
        await service.save()
        
        # Create verification assignments
        for provider_id in agent_ids:
            assignment = VerificationAssignment(
                serviceId=service_id,
                providerId=provider_id,
                assignedById=manager_id,
                status=VerificationStatus.PENDING,
            )
            await assignment.insert()
        
        return {
            "service": service.dict(),
            "availableNodalOfficers": available_officers,
            "assignedNodalOfficerId": final_nodal_officer_id,
            "needsRecommendation": len(available_officers) == 0,
        }
    
    @staticmethod
    async def find_nodal_officers_by_location(
        location: str,
        pincode: Optional[str] = None,
    ) -> List[dict]:
        """Find nodal officers by service location"""
        where_clause = {"status": NodalOfficerStatus.ACTIVE}
        if pincode:
            where_clause["pincode"] = pincode
        
        officers = await NodalOfficerAssignment.find(where_clause).to_list()
        
        # Filter by location case-insensitively
        filtered = [
            o for o in officers
            if location.lower() in o.location.lower()
        ]
        
        result = []
        for officer in filtered:
            officer_user = await User.get(officer.officer_id)
            result.append({
                "officerId": str(officer.officer_id),
                "officer": officer_user.dict() if officer_user else None,
                "area": officer.area,
                "location": officer.location,
            })
        
        return result
    
    @staticmethod
    async def verify_service(
        assignment_id: str,
        decision: VerificationStatus,
        notes: Optional[str] = None,
    ):
        """Verify a service assignment"""
        assignment = await VerificationAssignment.get(assignment_id)
        if not assignment:
            raise HttpError(404, "Assignment not found")
        
        assignment.status = decision
        if notes:
            assignment.notes = notes
        await assignment.save()
        
        if decision == VerificationStatus.APPROVED:
            # Count approvals
            approvals = await VerificationAssignment.find(
                {"serviceId": assignment.service_id, "status": "APPROVED"}
            ).count()
            
            if approvals >= 3:
                service = await ServiceListing.get(assignment.service_id)
                if service:
                    service.status = ServiceStatus.PUBLISHED
                    service.published_at = datetime.utcnow()
                    await service.save()
    
    @staticmethod
    async def list_assignments(provider_id: str) -> List[VerificationAssignment]:
        """List verification assignments for a provider"""
        assignments = await VerificationAssignment.find(
            {"providerId": provider_id}
        ).to_list()
        return assignments
    
    @staticmethod
    async def get_service_verification_assignments(service_id: str) -> List[dict]:
        """Get verification assignments for a service (for admins/managers to view progress)"""
        assignments = await VerificationAssignment.find(
            {"serviceId": service_id}
        ).to_list()
        
        result = []
        for assignment in assignments:
            # Get provider user info
            provider_user = await User.get(assignment.provider_id) if assignment.provider_id else None
            assigned_by_user = await User.get(assignment.assigned_by_id) if assignment.assigned_by_id else None
            
            assignment_dict = assignment.dict()
            assignment_dict["provider"] = {
                "id": str(provider_user.id),
                "email": provider_user.email,
                "fullName": provider_user.full_name,
                "phone": provider_user.phone,
            } if provider_user else None
            
            assignment_dict["assignedBy"] = {
                "id": str(assigned_by_user.id),
                "email": assigned_by_user.email,
                "fullName": assigned_by_user.full_name,
            } if assigned_by_user else None
            
            result.append(assignment_dict)
        
        return result
    
    @staticmethod
    async def onboard_provider(
        user_id: str,
        data: dict,
    ) -> ServiceProvider:
        """Onboard a service provider"""
        # Create/update role
        role = await Role.find_one(
            {"userId": user_id, "role": "PROVIDER"}
        )
        if not role:
            role = Role(userId=user_id, role=UserRole.PROVIDER)
            await role.insert()
        
        # Create/update provider profile
        provider = await ServiceProvider.find_one({"userId": user_id})
        if provider:
            provider.kyc_document_url = data.get("kycDocumentUrl")
            provider.pricing_details = data.get("pricingDetails")
            provider.photos = data.get("photoUrls", [])
            provider.status = ProviderStatus.PENDING
            await provider.save()
        else:
            provider = ServiceProvider(
                userId=user_id,
                kycDocumentUrl=data.get("kycDocumentUrl"),
                pricingDetails=data.get("pricingDetails"),
                photos=data.get("photoUrls", []),
                status=ProviderStatus.PENDING,
            )
            await provider.insert()
        
        return provider
    
    @staticmethod
    async def list_providers() -> List[dict]:
        """List approved providers"""
        try:
            providers = await ServiceProvider.find(
                {"status": "APPROVED"}
            ).to_list()
            
            result = []
            for provider in providers:
                try:
                    # Use find_one instead of get to avoid _id issues
                    user = None
                    if provider.user_id:
                        user = await User.find_one({"_id": provider.user_id})
                        if not user:
                            # Try as string ID
                            try:
                                from bson import ObjectId
                                user = await User.find_one({"_id": ObjectId(provider.user_id)})
                            except:
                                pass
                    
                    # Convert to dict, handling ObjectId serialization
                    provider_dict = {
                        "id": str(provider.id),
                        "userId": str(provider.user_id) if provider.user_id else None,
                        "kycDocumentUrl": provider.kyc_document_url,
                        "pricingDetails": provider.pricing_details,
                        "photos": provider.photos or [],
                        "status": provider.status.value if hasattr(provider.status, "value") else str(provider.status),
                    }
                    
                    user_dict = None
                    if user:
                        user_dict = {
                            "id": str(user.id),
                            "email": user.email,
                            "fullName": user.full_name,
                            "phone": user.phone,
                        }
                    
                    result.append({
                        **provider_dict,
                        "user": user_dict,
                    })
                except Exception as e:
                    logger.error(f"Error processing provider {provider.id}: {e}", exc_info=True)
                    continue
            
            return result
        except Exception as e:
            logger.error(f"Error in list_providers: {e}", exc_info=True)
            raise
    
    @staticmethod
    async def list_nodal_officers_by_area(
        manager_id: str,
        filters: Optional[dict] = None,
    ) -> List[dict]:
        """List nodal officers by area (for managers)"""
        manager_assignment = await ManagerAssignment.find_one({
            "managerId": manager_id
        })
        
        if not manager_assignment:
            raise HttpError(
                404,
                "Manager assignment not found. Please contact admin to assign you to a region.",
            )
        
        if manager_assignment.status != ManagerAssignmentStatus.ACTIVE:
            raise HttpError(403, "Manager assignment is not active")
        
        # Build filter
        where_clause = {"status": NodalOfficerStatus.ACTIVE}
        if manager_assignment.pincode:
            where_clause["pincode"] = manager_assignment.pincode
        
        officers = await NodalOfficerAssignment.find(where_clause).to_list()
        
        # Filter by location
        location_filter = filters.get("location") if filters else manager_assignment.location
        if location_filter:
            officers = [
                o for o in officers
                if location_filter.lower() in o.location.lower()
            ]
        
        # Additional filters
        if filters:
            if filters.get("area"):
                officers = [
                    o for o in officers
                    if filters["area"].lower() in o.area.lower()
                ]
            if filters.get("pincode"):
                officers = [o for o in officers if o.pincode == filters["pincode"]]
        
        result = []
        for officer in officers:
            officer_user = await User.get(officer.officer_id)
            result.append({
                **officer.dict(),
                "officer": officer_user.dict() if officer_user else None,
            })
        
        return result
    
    @staticmethod
    async def recommend_nodal_officer(
        manager_id: str,
        data: dict,
    ) -> NodalOfficerRecommendation:
        """Recommend a nodal officer"""
        if not data.get("officerId") and not (data.get("newUserEmail") and data.get("newUserFullName")):
            raise HttpError(
                400,
                "Either officerId or new user details (email, fullName) must be provided",
            )
        
        # Validate existing officer
        if data.get("officerId"):
            officer = await User.get(data["officerId"])
            if not officer:
                raise HttpError(404, "Officer not found")
            
            roles = await Role.find({"userId": str(officer.id)}).to_list()
            has_role = any(role.role == UserRole.NODAL_OFFICER for role in roles)
            if not has_role:
                raise HttpError(400, "User does not have NODAL_OFFICER role")
        
        # Check for existing recommendation
        existing = await NodalOfficerRecommendation.find_one(
            {"managerId": manager_id, "area": data["area"], "location": data["location"], "status": "PENDING"}
        )
        
        if existing:
            raise HttpError(409, "Recommendation already pending for this officer and area")
        
        # Create recommendation
        recommendation = NodalOfficerRecommendation(
            managerId=manager_id,
            officerId=data.get("officerId"),
            newUserEmail=data.get("newUserEmail"),
            newUserFullName=data.get("newUserFullName"),
            newUserPhone=data.get("newUserPhone"),
            area=data["area"],
            location=data["location"],
            address=data.get("address"),
            pincode=data.get("pincode"),
            region=data.get("region"),
            reason=data.get("reason"),
            status=RecommendationStatus.PENDING,
        )
        await recommendation.insert()
        
        return recommendation
    
    @staticmethod
    async def list_manager_recommendations(manager_id: str) -> List[dict]:
        """List recommendations by a manager"""
        recommendations = await NodalOfficerRecommendation.find(
            {"managerId": manager_id}
        ).to_list()
        
        result = []
        for rec in recommendations:
            officer = await User.get(rec.officer_id) if rec.officer_id else None
            result.append({
                **rec.dict(),
                "officer": officer.dict() if officer else None,
            })
        
        return result
    
    @staticmethod
    async def get_manager_assignment(manager_id: str) -> Optional[dict]:
        """Get manager assignment"""
        assignment = await ManagerAssignment.find_one({
            "managerId": manager_id
        })
        return assignment.dict() if assignment else None
    
    @staticmethod
    async def list_navbar_categories() -> List[dict]:
        """List service categories for navbar"""
        categories = await ServiceCategory.find(
            {"showInNavbar": True, "isActive": True}
        ).to_list()
        
        # Sort by display_order
        categories.sort(key=lambda c: c.display_order)
        
        return [
            {
                "id": str(c.id),
                "name": c.name,
                "description": c.description,
                "displayOrder": c.display_order,
            }
            for c in categories
        ]
    
    @staticmethod
    async def get_available_nodal_officers_for_service(service_id: str) -> dict:
        """Get available nodal officers for a service"""
        service = await ServiceListing.get(service_id)
        if not service:
            raise HttpError(404, "Service not found")
        
        officers = await ServiceService.find_nodal_officers_by_location(
            service.location,
            service.pincode,
        )
        
        return {
            "availableOfficers": officers,
            "needsRecommendation": len(officers) == 0,
            "serviceLocation": service.location,
            "servicePincode": service.pincode,
        }

