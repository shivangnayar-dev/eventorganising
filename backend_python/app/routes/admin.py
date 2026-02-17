"""
Admin routes
"""
from fastapi import APIRouter, Depends, Query
from typing import Optional
from pydantic import BaseModel
from app.middleware.auth_middleware import require_roles
from app.services.admin_service import AdminService

# All admin routes require ADMIN role
router = APIRouter(dependencies=[Depends(require_roles("ADMIN"))])


# Request models
class CreateManagerRequest(BaseModel):
    email: str
    fullName: str
    password: str
    phone: Optional[str] = None
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    notes: Optional[str] = None


class UpdateManagerRequest(BaseModel):
    fullName: Optional[str] = None
    password: Optional[str] = None
    phone: Optional[str] = None
    area: Optional[str] = None
    location: Optional[str] = None
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    notes: Optional[str] = None


class AssignManagerRequest(BaseModel):
    serviceId: str
    managerId: str


class CreateNodalOfficerRequest(BaseModel):
    email: str
    fullName: str
    password: str
    phone: Optional[str] = None
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    notes: Optional[str] = None


class AssignOfficerToAreaRequest(BaseModel):
    officerId: str
    area: str
    location: str
    address: Optional[str] = None
    pincode: Optional[str] = None
    region: Optional[str] = None
    notes: Optional[str] = None


class CreateServiceCategoryRequest(BaseModel):
    name: str
    description: Optional[str] = None
    showInNavbar: Optional[bool] = False
    displayOrder: Optional[int] = 0
    isActive: Optional[bool] = True


class UpdateServiceCategoryRequest(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    showInNavbar: Optional[bool] = None
    displayOrder: Optional[int] = None
    isActive: Optional[bool] = None


class CreateFormFieldConfigRequest(BaseModel):
    fieldKey: str
    label: str
    fieldType: str
    isRequired: Optional[bool] = False
    isEnabled: Optional[bool] = True
    displayOrder: Optional[int] = 0
    validation: Optional[dict] = None
    options: Optional[list] = None
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    step: Optional[str] = None


class UpdateFormFieldConfigRequest(BaseModel):
    fieldKey: Optional[str] = None
    label: Optional[str] = None
    fieldType: Optional[str] = None
    isRequired: Optional[bool] = None
    isEnabled: Optional[bool] = None
    displayOrder: Optional[int] = None
    validation: Optional[dict] = None
    options: Optional[list] = None
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    step: Optional[str] = None


class CreateVerificationCheckpointConfigRequest(BaseModel):
    checkpointKey: str
    label: str
    checkpointType: str
    description: Optional[str] = None
    isRequired: Optional[bool] = True
    isEnabled: Optional[bool] = True
    displayOrder: Optional[int] = 0
    validation: Optional[dict] = None
    options: Optional[list] = None
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    category: Optional[str] = None


class UpdateVerificationCheckpointConfigRequest(BaseModel):
    checkpointKey: Optional[str] = None
    label: Optional[str] = None
    checkpointType: Optional[str] = None
    description: Optional[str] = None
    isRequired: Optional[bool] = None
    isEnabled: Optional[bool] = None
    displayOrder: Optional[int] = None
    validation: Optional[dict] = None
    options: Optional[list] = None
    placeholder: Optional[str] = None
    hint: Optional[str] = None
    category: Optional[str] = None


class RejectRecommendationRequest(BaseModel):
    notes: Optional[str] = None


# Routes
@router.get("/dashboard")
async def dashboard(user: dict = Depends(require_roles("ADMIN"))):
    """Admin dashboard"""
    data = await AdminService.dashboard()
    return data


@router.get("/users")
async def users(user: dict = Depends(require_roles("ADMIN"))):
    """List all users"""
    users_list = await AdminService.list_users()
    return users_list


@router.get("/services")
async def services(user: dict = Depends(require_roles("ADMIN"))):
    """List all services"""
    services_list = await AdminService.list_services()
    return services_list


@router.get("/verifications")
async def verifications(user: dict = Depends(require_roles("ADMIN"))):
    """List all verification assignments"""
    verifications_list = await AdminService.list_verifications()
    return verifications_list


@router.post("/create-manager")
async def create_manager(
    data: CreateManagerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a new manager"""
    manager = await AdminService.create_manager(data.model_dump(), user.get("id"))
    return manager


@router.post("/managers")
async def create_manager_alias(
    data: CreateManagerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a new manager (alias for /create-manager)"""
    try:
        manager = await AdminService.create_manager(data.model_dump(), user.get("id"))
        return manager
    except Exception as e:
        from app.config.logger import setup_logger
        logger = setup_logger()
        logger.error(f"Error creating manager: {e}", exc_info=True)
        raise


@router.put("/managers/{id}")
async def update_manager(
    id: str,
    data: UpdateManagerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Update a manager"""
    manager = await AdminService.update_manager(id, data.model_dump(exclude_unset=True))
    return manager


@router.delete("/managers/{id}")
async def delete_manager(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Delete a manager"""
    await AdminService.delete_manager(id)
    return {"message": "Manager deleted successfully"}


@router.post("/assign-manager")
async def assign_manager(
    data: AssignManagerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Assign a manager to a service"""
    service = await AdminService.assign_manager(data.serviceId, data.managerId)
    return service


@router.post("/create-nodal-officer")
async def create_nodal_officer(
    data: CreateNodalOfficerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a new nodal officer"""
    officer = await AdminService.create_nodal_officer(data.model_dump(), user.get("id"))
    return officer


@router.post("/nodal-officers")
async def create_nodal_officer_alias(
    data: CreateNodalOfficerRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a new nodal officer (alias for /create-nodal-officer)"""
    officer = await AdminService.create_nodal_officer(data.model_dump(), user.get("id"))
    return officer


@router.get("/nodal-officers")
async def list_nodal_officers(
    location: Optional[str] = Query(None),
    area: Optional[str] = Query(None),
    pincode: Optional[str] = Query(None),
    user: dict = Depends(require_roles("ADMIN")),
):
    """List nodal officers"""
    filters = {}
    if location:
        filters["location"] = location
    if area:
        filters["area"] = area
    if pincode:
        filters["pincode"] = pincode
    
    officers = await AdminService.list_nodal_officers(filters)
    return officers


@router.post("/assign-officer-to-area")
async def assign_officer_to_area(
    data: AssignOfficerToAreaRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Assign an officer to an area"""
    assignment = await AdminService.assign_officer_to_area(
        data.officerId,
        data.model_dump(exclude={"officerId"}),
        user.get("id"),
    )
    return assignment


@router.post("/nodal-officers/assign")
async def assign_officer_to_area_alias(
    data: AssignOfficerToAreaRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Assign an officer to an area (alias for /assign-officer-to-area)"""
    assignment = await AdminService.assign_officer_to_area(
        data.officerId,
        data.model_dump(exclude={"officerId"}),
        user.get("id"),
    )
    return assignment


@router.get("/recommendations")
async def list_recommendations(
    status: Optional[str] = Query(None),
    user: dict = Depends(require_roles("ADMIN")),
):
    """List nodal officer recommendations"""
    recommendations = await AdminService.list_recommendations(status)
    return recommendations


@router.post("/recommendations/{id}/approve")
async def approve_recommendation(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Approve a recommendation"""
    recommendation = await AdminService.approve_recommendation(id, user.get("id", ""))
    return recommendation


@router.post("/recommendations/{id}/reject")
async def reject_recommendation(
    id: str,
    data: RejectRecommendationRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Reject a recommendation"""
    recommendation = await AdminService.reject_recommendation(
        id,
        user.get("id", ""),
        data.notes,
    )
    return recommendation


@router.get("/service-categories")
async def list_service_categories(user: dict = Depends(require_roles("ADMIN"))):
    """List all service categories"""
    categories = await AdminService.list_service_categories()
    return categories


@router.post("/service-categories")
async def create_service_category(
    data: CreateServiceCategoryRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a service category"""
    category = await AdminService.create_service_category(data.model_dump())
    return category.model_dump(mode="json", by_alias=True)


@router.put("/service-categories/{id}")
async def update_service_category(
    id: str,
    data: UpdateServiceCategoryRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Update a service category"""
    category = await AdminService.update_service_category(id, data.model_dump(exclude_unset=True))
    return category.model_dump(mode="json", by_alias=True)


@router.delete("/service-categories/{id}")
async def delete_service_category(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Delete a service category"""
    await AdminService.delete_service_category(id)
    return {"message": "Service category deleted"}


@router.get("/form-fields")
async def list_form_field_configs(user: dict = Depends(require_roles("ADMIN"))):
    """List all form field configurations"""
    fields = await AdminService.list_form_field_configs()
    return fields


@router.get("/form-fields/{id}")
async def get_form_field_config(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Get a single form field configuration"""
    field = await AdminService.get_form_field_config(id)
    return field


@router.post("/form-fields")
async def create_form_field_config(
    data: CreateFormFieldConfigRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a form field configuration"""
    field = await AdminService.create_form_field_config(data.model_dump())
    field_dict = field.model_dump(mode="json", by_alias=True)
    field_dict["fieldType"] = field.field_type.value if hasattr(field.field_type, "value") else str(field.field_type)
    return field_dict


@router.put("/form-fields/{id}")
async def update_form_field_config(
    id: str,
    data: UpdateFormFieldConfigRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Update a form field configuration"""
    field = await AdminService.update_form_field_config(id, data.model_dump(exclude_unset=True))
    field_dict = field.model_dump(mode="json", by_alias=True)
    field_dict["fieldType"] = field.field_type.value if hasattr(field.field_type, "value") else str(field.field_type)
    return field_dict


@router.delete("/form-fields/{id}")
async def delete_form_field_config(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Delete a form field configuration"""
    await AdminService.delete_form_field_config(id)
    return {"message": "Form field configuration deleted"}


@router.get("/verification-checkpoints")
async def list_verification_checkpoint_configs(user: dict = Depends(require_roles("ADMIN"))):
    """List all verification checkpoint configurations"""
    checkpoints = await AdminService.list_verification_checkpoint_configs()
    return checkpoints


@router.get("/verification-checkpoints/{id}")
async def get_verification_checkpoint_config(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Get a single verification checkpoint configuration"""
    checkpoint = await AdminService.get_verification_checkpoint_config(id)
    return checkpoint


@router.post("/verification-checkpoints")
async def create_verification_checkpoint_config(
    data: CreateVerificationCheckpointConfigRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Create a verification checkpoint configuration"""
    checkpoint = await AdminService.create_verification_checkpoint_config(data.model_dump())
    checkpoint_dict = checkpoint.model_dump(mode="json", by_alias=True)
    checkpoint_dict["checkpointType"] = checkpoint.checkpoint_type.value if hasattr(checkpoint.checkpoint_type, "value") else str(checkpoint.checkpoint_type)
    return checkpoint_dict


@router.put("/verification-checkpoints/{id}")
async def update_verification_checkpoint_config(
    id: str,
    data: UpdateVerificationCheckpointConfigRequest,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Update a verification checkpoint configuration"""
    checkpoint = await AdminService.update_verification_checkpoint_config(id, data.model_dump(exclude_unset=True))
    checkpoint_dict = checkpoint.model_dump(mode="json", by_alias=True)
    checkpoint_dict["checkpointType"] = checkpoint.checkpoint_type.value if hasattr(checkpoint.checkpoint_type, "value") else str(checkpoint.checkpoint_type)
    return checkpoint_dict


@router.delete("/verification-checkpoints/{id}")
async def delete_verification_checkpoint_config(
    id: str,
    user: dict = Depends(require_roles("ADMIN")),
):
    """Delete a verification checkpoint configuration"""
    await AdminService.delete_verification_checkpoint_config(id)
    return {"message": "Verification checkpoint configuration deleted"}
