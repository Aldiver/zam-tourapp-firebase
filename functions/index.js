/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.updateRatingAggregates = functions.firestore
    .document("ratings/{ratingId}")
    .onWrite(async (change, context) => {
      const newRating = change.after.exists ? change.after.data() : null;
      const oldRating = change.before.exists ? change.before.data() : null;

      const destinationId = newRating ?
            newRating.destinationId : oldRating.destinationId;
      const destinationRef = admin.firestore().collection("destinations")
          .doc(destinationId);

      try {
        const ratingsSnapshot = await admin.firestore()
            .collection("ratings")
            .where("destinationId", "==", destinationId)
            .get();

        let totalRating = 0;
        let ratingCount = 0;

        ratingsSnapshot.forEach((doc) => {
          totalRating += doc.data().rating;
          ratingCount++;
        });

        const averageRating = ratingCount === 0 ? 0 : totalRating / ratingCount;

        await destinationRef.update({
          aveRating: averageRating,
          rating: ratingCount,
        });

        console.log(`Updated destination ${destinationId} with aveRating: 
        ${averageRating}, rating: ${ratingCount}`);
      } catch (error) {
        console.error("Error updating rating aggregates:", error);
      }
    });

