const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

initializeApp();

setGlobalOptions({
    maxInstances: 10,
});

exports.sendChatNotification = onDocumentCreated(
    "consultations/{consultationId}/messages/{messageId}",
    async (event) => {
        try {
            const messageSnapshot = event.data;

            if (!messageSnapshot) {
                logger.warn("Data pesan tidak ditemukan.");
                return;
            }

            const messageData = messageSnapshot.data();

            const consultationId = event.params.consultationId;
            const messageId = event.params.messageId;

            const senderId = messageData.senderId?.toString() ?? "";
            const senderRole =
                messageData.senderRole?.toString().trim().toLowerCase() ?? "";
            const message =
                messageData.message?.toString().trim() ?? "";

            if (!senderId || !senderRole || !message) {
                logger.warn("Data pesan tidak lengkap.", {
                    consultationId,
                    messageId,
                    senderId,
                    senderRole,
                });
                return;
            }

            // Ambil data konsultasi
            const db = getFirestore();

            const consultationRef = db
                .collection("consultations")
                .doc(consultationId);

            const consultationSnapshot = await consultationRef.get();

            if (!consultationSnapshot.exists) {
                logger.warn("Dokumen konsultasi tidak ditemukan.", {
                    consultationId,
                });
                return;
            }

            const consultation = consultationSnapshot.data() || {};

            const doctorId = consultation.doctorId?.toString() ?? "";
            const userId = consultation.userId?.toString() ?? "";

            const doctorName =
                consultation.doctorName?.toString().trim() || "Dokter";

            const userName =
                consultation.userName?.toString().trim() || "Pasien";

            let recipientId = "";
            let title = "";
            let body = "";

            // USER mengirim pesan → kirim notif ke DOKTER
            if (senderRole === "user") {
                recipientId = doctorId;

                title = `Pesan Baru dari ${userName}`;
                body = message;
            }

            // DOKTER mengirim pesan → kirim notif ke USER
            else if (senderRole === "doctor" || senderRole === "dokter") {
                recipientId = userId;

                title = `Dokter ${doctorName} Membalas Pesanmu`;
                body = message;
            }

            // Role tidak dikenali
            else {
                logger.warn("senderRole tidak dikenali.", {
                    senderRole,
                    consultationId,
                    messageId,
                });
                return;
            }

            if (!recipientId) {
                logger.warn("ID penerima tidak ditemukan.", {
                    senderRole,
                    consultationId,
                    messageId,
                });
                return;
            }

            // Ambil FCM token penerima
            const recipientRef = db
                .collection("users")
                .doc(recipientId);

            const recipientSnapshot = await recipientRef.get();

            if (!recipientSnapshot.exists) {
                logger.warn("Dokumen user penerima tidak ditemukan.", {
                    recipientId,
                });
                return;
            }

            const recipientData = recipientSnapshot.data() || {};

            const fcmToken =
                recipientData.fcmToken?.toString().trim() ?? "";

            if (!fcmToken) {
                logger.warn("FCM token penerima tidak tersedia.", {
                    recipientId,
                    consultationId,
                    messageId,
                });
                return;
            }

            // Kirim push notification melalui FCM
            await getMessaging().send({
                token: fcmToken,

                notification: {
                    title: title,
                    body: body,
                },

                data: {
                    type: "chat",
                    consultationId: consultationId,
                    messageId: messageId,
                    senderId: senderId,
                    senderRole: senderRole,
                },

                android: {
                    notification: {
                        channelId: "chat_message",
                        sound: "default",
                    },
                },
            });

            logger.info("Chat notification berhasil dikirim.", {
                consultationId,
                messageId,
                senderRole,
                recipientId,
            });
        } catch (error) {
            logger.error("Gagal mengirim chat notification.", error);
        }
    },
);