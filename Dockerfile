# बेस इमेज
FROM python:3.11-slim AS backend

# आवश्यक पैकेज इंस्टॉल करें
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && apt-get clean

# कार्य निर्देशिका सेट करें
WORKDIR /app

# आवश्यक फाइलें कॉपी करें
COPY requirements.txt .
COPY backend backend

# निर्भरताएँ इंस्टॉल करें
RUN pip install --no-cache-dir -r requirements.txt

# फ्रंटएंड बिल्ड स्टेप
FROM node:18 AS frontend

# कार्य निर्देशिका सेट करें
WORKDIR /app/frontend

# आवश्यक फाइलें कॉपी करें
COPY frontend/package.json frontend/package-lock.json ./

# निर्भरताएँ इंस्टॉल करें और बिल्ड करें
RUN npm install && npm run build

# अंतिम स्टेप
FROM backend AS final

# कार्य निर्देशिका सेट करें
WORKDIR /app

# फ्रंटएंड बिल्ड आउटपुट कॉपी करें
COPY --from=frontend /app/frontend/build backend/static

# पोर्ट एक्सपोज़ करें
EXPOSE 1337

# कमांड सेट करें
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "1337"]
