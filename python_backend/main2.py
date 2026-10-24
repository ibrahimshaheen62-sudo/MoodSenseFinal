import uvicorn
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI

# ==========================================
# 1. إعدادات المشروع (عبئ بياناتك هنا)
# ==========================================

# ضع مفتاح OpenAI الحقيقي هنا
API_KEY = "YOUR_OPENAI_API_KEY"

# ضع اسم الموديل الذي دربته (الذي يبدأ بـ ft:gpt...)
# ستجده في إيميل OpenAI أو في لوحة التحكم بعد انتهاء التدريب
FINE_TUNED_MODEL = "gpt-4.1-nano"

# ==========================================
# 2. تهيئة التطبيق
# ==========================================
app = FastAPI()
client = OpenAI(api_key=API_KEY)

# السماح بالاتصال من أي مكان (لضمان عمل Flutter بدون مشاكل)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==========================================
# 3. تعريف هيكل البيانات (مطابق للـ Flutter)
# ==========================================
# Flutter يرسل: {"message": "نص المستخدم"}
class UserRequest(BaseModel):
    message: str 

# ==========================================
# 4. نقطة الاتصال (Endpoint)
# ==========================================
@app.post("/chat")
async def chat_endpoint(req: UserRequest):
    try:
        print(f"📩 وصلتنا رسالة من التطبيق: {req.message}")

        # إرسال الرسالة إلى موديلك المدرب
        response = client.chat.completions.create(
            model=FINE_TUNED_MODEL,
            messages=[
                # الـ System Prompt مهم جداً ليعرف الموديل دوره
                # (نفس الجملة التي استخدمتها في ملف التدريب jsonl)
                {"role": "system", "content": "أنت مساعد صحة نفسية متعاطف ولطيف."},
                
                # رسالة المستخدم القادمة من Flutter
                {"role": "user", "content": req.message}
            ],
            temperature=0.7, # نسبة الإبداع (0.7 ممتازة للتوازن)
        )

        # استخراج نص الرد فقط
        bot_reply = response.choices[0].message.content
        print(f"📤 الرد الذي سنرسله للتطبيق: {bot_reply}")

        # إرجاع الرد بنفس الاسم الذي ينتظره Flutter وهو "reply"
        return {"reply": bot_reply}

    except Exception as e:
        print(f"❌ حدث خطأ: {e}")
        # إعادة الخطأ للتطبيق لكي يظهر في الـ Console هناك
        raise HTTPException(status_code=500, detail=str(e))

# ==========================================
# 5. تشغيل السيرفر
# ==========================================
if __name__ == "__main__":
    # 0.0.0.0 تعني أن السيرفر متاح للشبكة المحلية وليس فقط للجهاز نفسه
    print("🚀 جاري تشغيل السيرفر... تأكد أن الموبايل واللابتوب على نفس الواي فاي")
    uvicorn.run(app, host="0.0.0.0", port=8001)