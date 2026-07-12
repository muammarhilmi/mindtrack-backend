from pydantic import BaseModel


class JournalCreate(BaseModel):
    user_id: str
    title: str
    content: str
    mood: str