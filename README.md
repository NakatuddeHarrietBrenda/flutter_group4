# NutriBlend v2.0 - Authenticated Android E-Commerce Flow
**WOMEN'S INSTITUTE OF TECHNOLOGY AND INNOVATION (WITI)**  
**Diploma in Computer Science - Year 2, Semester 2 Take-Home Group Exam**  
**Course Code**: CSD213: Intermediate Android Development  
**Academic Year**: 2025/2026  
**Due Date**: Wednesday, 10th June 2026, 5:00 PM  

---

## 📋 Course Group Submission Details
Only the **Group Leader** should submit all final work using the official Exam Submission Portal: [Google Form Link](https://forms.gle/RXMHtRjDAwtWxxg68).

| Role | Student Name | Registration / ID Number |
| :--- | :--- | :--- |
| **Group Leader** | Nakatudde Harriet | *[Insert ID]* |
| **Member 2** | Ampurire Brendah | *[Insert ID]* |
| **Member 3** | Sarafina Niwahereza | *[Insert ID]* |
| **Member 4** | Charity Wanyetse | *[Insert ID]* |
| **Member 5** | Edith Nabwire | *[Insert ID]* |
| **Member 6** | Nanjego Afuwa | *[Insert ID]* |

- **GitHub Repository URL**: https://github.com/NakatuddeHarrietBrenda/flutter_group4
- **Google Drive APK URL**: `[Insert Google Drive Link Here (Set permission to "Anyone with the link can view")]`

---

## 🚀 Key Implementations (Exam Objectives Met)

### Section A: API Integration & Authentication (35 Marks)
1. **POST `/api/v1/auth/register` (Registration Screen)**: Creates user account (Name, Email/Contact, and Password). Includes automatic login on successful creation.
2. **POST `/api/v1/auth/login` (Login Screen)**: Authenticates credentials. On success, the API session token is extracted and persisted using `SharedPreferences` for session restoration.
3. **GET `/api/v1/products` (Products Screen)**: Dynamically fetches luxury fragrance listings from the backend. Incorporates a Shimmer skeleton loader while fetching.
4. **GET `/api/v1/regions` & `/api/v1/regions/{region_id}/towns` (Checkout Screen)**: Populates cascading Region and Town dropdown menus. Selecting a region dynamically fetches and populates its associated towns from the backend.
5. **POST `/api/v1/orders` (Place Order)**: Dispatches order details securely using the `Authorization: Bearer <token>` header, sending customer name, phone, delivery method, region, town, physical address, and items.

### Section B: State Management with Provider (20 Marks)
- **`CartProvider`**: Manages global cart state (selected products, quantities, prices, and sums). Ensures that removing an item immediately updates the badges, sums, and lists across the Home screen, Cart screen, and Checkout screens.
- **`AuthProvider`**: Manages user authentication state globally (log in, log out, session restoration, error handling, and guest mode).

### Section C: UI/UX Modern Loading States (20 Marks)
- **Shimmer Effects**: GET requests on `ProductScreen` and `CheckoutScreen` display custom shimmer layouts that resemble the product grid and cascading loaders to represent content skeleton states.
- **Submit Loading Indicators**: POST forms (Login, Register, and Checkout) disable submit buttons to block duplicate submissions and show a circular progress loader.

---

## 🛠️ Local Development and Run Guide

For ease of testing and grading, this codebase contains a self-contained local Python Flask backend that matches the RESTful specifications.

### 1. Run the Local Backend
Navigate to the `/backend` folder, install requirements, and run the server:
```bash
# Navigate to backend
cd backend

# Install dependencies (Flask & Flask-CORS)
pip install -r requirements.txt

# Start the local server
python app.py
```
*The Flask backend will create a local SQLite database (`nutriblend.db`) and run on `http://localhost:5000`.*

### 2. Run the Flutter App
To launch the Flutter app on Chrome:
```bash
flutter run -d chrome
```
*If Chrome enforces strict CORS blocks on localhost endpoints, launch with Web Security disabled:*
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

---

## 📱 Application Screenshots

### 🔑 Splash Screen
![Splash Screen](image.png)

### 🏠 Home and Products Screen
![Home Screen](image-1.png)

### 💖 Wishlist Screen
![Wishlist Screen](image-2.png)

### 🛒 Cart Screen
![Cart Screen](image-3.png)

### 👤 Profile Screen
![Profile Screen](image-4.png)

---

## 📦 How to Build the Release APK
To build the signed release APK for your Android submission:
1. Ensure your Flutter environment is configured for Android builds.
2. Run the build command in the root folder:
   ```bash
   flutter build apk --release
   ```
3. Locate the built APK at `build/app/outputs/flutter-apk/app-release.apk`.
4. Upload it to your group's Google Drive and copy the shared link.