FROM python:3.8-slim-buster

# Устанавливаем зависимости
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

# Копируем файлы приложения
COPY ./main.py /app/main.py

# Запускаем приложение
CMD ["python", "/app/main.py"]
