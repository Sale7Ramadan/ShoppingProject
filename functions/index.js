const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendProductNotification = functions.firestore
    .document('products/{productId}')
    .onCreate(async (snap, context) => {
        const productsRef = admin.firestore().collection('products');
        const productsSnapshot = await productsRef.get();
        const productCount = productsSnapshot.size;

        // تحقق إذا كان العدد أكبر من 20
        if (productCount > 20) {
            const payload = {
                notification: {
                    title: "تم إضافة منتجات جديدة",
                    body: "تم إضافة أكثر من 20 منتج جديد في المتجر! تحقق الآن.",
                },
            };

            // إرسال الإشعار لجميع المستخدمين
            const usersRef = admin.firestore().collection('users');
            const usersSnapshot = await usersRef.get();
            usersSnapshot.forEach(async (doc) => {
                const userToken = doc.data().fcmToken;  // تأكد من تخزين فامي توكن للمستخدمين
                if (userToken) {
                    await admin.messaging().sendToDevice(userToken, payload);
                }
            });
        }
    });
