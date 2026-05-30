from fastapi import APIRouter, Depends, HTTPException, status

from app.dependencies.auth import get_current_user
from app.schemas.user import MessageResponse, UserCreate, UserResponse, UserUpdate
from app.services.user_service import (
    create_user,
    delete_user,
    get_user_by_id,
    list_users,
    update_user,
    user_to_response,
)

router = APIRouter(
    prefix="/users",
    tags=["Users"],
    dependencies=[Depends(get_current_user)],
)


@router.get("/", response_model=list[UserResponse], summary="List semua user")
def get_all_users():
    return list_users()


@router.get("/{user_id}", response_model=UserResponse, summary="Detail user by ID")
def get_user(user_id: str):
    user = get_user_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User tidak ditemukan")
    return user_to_response(user)


@router.post(
    "/",
    response_model=UserResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Buat user baru (CRUD)",
)
def create_user_endpoint(data: UserCreate):
    return create_user(data)


@router.put("/{user_id}", response_model=UserResponse, summary="Update user by ID")
def update_user_endpoint(user_id: str, data: UserUpdate):
    return update_user(user_id, data)


@router.delete(
    "/{user_id}",
    response_model=MessageResponse,
    summary="Hapus user by ID",
)
def delete_user_endpoint(user_id: str):
    delete_user(user_id)
    return MessageResponse(message="User berhasil dihapus")
