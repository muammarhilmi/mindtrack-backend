from fastapi import APIRouter, Depends, status

from app.core.security import create_access_token
from app.dependencies.auth import get_current_user
from app.schemas.user import (
    GoogleLoginRequest,
    MessageResponse,
    TokenResponse,
    UserCreate,
    UserLogin,
    UserResponse,
    UserUpdate,
)
from app.services.user_service import (
    authenticate_user,
    create_user,
    login_or_register_with_google,
    update_user,
    user_to_response,
)

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post(
    "/register",
    response_model=MessageResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Daftar akun baru",
)
def register(data: UserCreate):
    create_user(data)
    return MessageResponse(message="Registrasi berhasil")


@router.post(
    "/login",
    response_model=TokenResponse,
    summary="Login dan dapatkan JWT token",
)
def login(data: UserLogin):
    user = authenticate_user(data.email, data.password)
    token = create_access_token(user["email"])
    return TokenResponse(access_token=token)


@router.post(
    "/google",
    response_model=TokenResponse,
    summary="Login / register via Google ID token",
)
def google_login(data: GoogleLoginRequest):
    user = login_or_register_with_google(data.id_token)
    token = create_access_token(user["email"])
    return TokenResponse(access_token=token)


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Profil user yang sedang login",
)
def me(current_user: dict = Depends(get_current_user)):
    return user_to_response(current_user)


@router.put(
    "/profile",
    response_model=UserResponse,
    summary="Update profil user yang sedang login",
)
def update_profile(
    data: UserUpdate,
    current_user: dict = Depends(get_current_user),
):
    return update_user(str(current_user["_id"]), data)
