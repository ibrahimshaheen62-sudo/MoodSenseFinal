# Mood Sense — AI-Powered Mental Health Mobile Application

Mood Sense is a graduation project developed to provide users with an accessible, supportive, and interactive mental health experience through artificial intelligence.

The application allows users to communicate with an AI-powered assistant, receive personalized well-being suggestions, and manage their conversations through a mobile interface built with Flutter.

## Key Features

- **AI-Powered Chat:** Interactive conversations with an AI assistant designed to provide empathetic and supportive responses.
- **User Authentication:** Firebase Authentication integration for user sign-in and account management.
- **Conversation History:** Firebase Firestore integration for storing and retrieving conversations.
- **Personalized Support:** Well-being recommendations and supportive guidance based on user interactions.
- **Mental Health Awareness:** AI-assisted emotional support and guidance toward professional assistance when appropriate.
- **Mobile Interface:** A Flutter-based application designed for an accessible user experience.

## Technologies Used

**Frontend**
- Flutter
- Dart

**Backend**
- Python
- FastAPI
- RESTful APIs

**Database & Authentication**
- Firebase Authentication
- Cloud Firestore

**Artificial Intelligence**
- OpenAI API
- GPT-based conversational AI

## Project Architecture

The application uses a Flutter frontend connected to Firebase services for authentication and data management.

A Python FastAPI backend handles communication with the OpenAI API and returns AI-generated responses to the mobile application.

## Running the Project

1. Clone the repository.
2. Install Flutter and the required project dependencies.
3. Configure Firebase for the Flutter application.
4. Install the Python dependencies from `python_backend/requirements.txt`.
5. Provide your own valid OpenAI API key in the backend configuration.
6. Start the FastAPI backend.
7. Configure the Flutter application to connect to the backend server.
8. Run the Flutter application using Android Studio or another supported Flutter development environment.

**Important:** This repository does not include an active OpenAI API key. AI functionality requires your own API credentials and may incur usage charges.

## Project Purpose

Mood Sense was developed as a Computer Science graduation project to demonstrate the integration of mobile application development, backend APIs, cloud-based authentication, database management, and artificial intelligence into a single application.

## Disclaimer

Mood Sense is intended for educational and general emotional support purposes. It is not a medical diagnostic tool and does not replace professional mental health care.
