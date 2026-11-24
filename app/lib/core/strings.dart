/// All user-visible English strings.
///
/// NEVER hard-code UI text inside widget or screen files.
/// When Hindi is added in Phase 6, a parallel source is created
/// and screen code is NOT changed — it always reads from this layer.
library;

class Strings {
  Strings._();

  // ── App-wide ─────────────────────────────────────────────────────────
  static const appName = 'PillSafe';
  static const disclaimer =
      'This is a helping tool. Please confirm with your doctor or pharmacist.';

  // ── Home ─────────────────────────────────────────────────────────────
  static const homeTitle = 'PillSafe';
  static const homeScan = 'Scan medicine';
  static const homeMyMeds = 'My medicines';

  // ── Scan placeholder ─────────────────────────────────────────────────
  static const scanTitle = 'Scan medicine';
  static const scanComingSoon =
      'Camera scanning will be available soon.\n'
      'For now, please type the medicine name.';
  static const scanTypeInstead = 'Type the name instead';

  // ── Find / Add medicine ───────────────────────────────────────────────
  static const findTitle = 'Find medicine';
  static const findHint = 'Type medicine name…';
  static const findResultsHelp = 'Tap a result to review it before adding.';
  static const findNoResults =
      'No medicines found.\nPlease check the spelling and try again.';

  // ── Confirm ───────────────────────────────────────────────────────────
  static const confirmTitle = 'Is this correct?';
  static const confirmQuestion = 'Did you find:';
  static const confirmIngredientLabel = 'Active ingredient:';
  static const confirmNoIngredient =
      'No active ingredient is known for this medicine.\n'
      'It will show as "Could not check" in results.';
  static const confirmYes = 'Yes, add it';
  static const confirmNo = 'No, search again';

  // ── My Medicines ──────────────────────────────────────────────────────
  static const myMedsTitle = 'My medicines';
  static const myMedsEmpty =
      'You have not added any medicines yet.\n'
      'Tap "Add a medicine" to begin.';
  static const myMedsAdd = 'Add a medicine';
  static const myMedsScan = 'Scan another';
  static const myMedsCheck = 'Check my medicines';
  static const myMedsRemove = 'Remove';
  static const myMedsRemoveDialogTitle = 'Remove medicine?';
  static const myMedsRemoveDialogBody =
      'Remove this medicine from your list?';
  static const myMedsRemoveYes = 'Yes, remove it';
  static const myMedsRemoveNo = 'Cancel';
  static const myMedsIngredientPrefix = 'Ingredient: ';
  static const myMedsNoIngredient = 'Ingredient unknown';

  // ── Result ────────────────────────────────────────────────────────────
  static const resultTitle = 'Check result';
  static const resultCallButton = 'Call my doctor / family';
  static const resultCallDialogTitle = 'Calling not set up yet';
  static const resultCallDialogBody =
      'Calling is not set up in this version.\n'
      'Please call your doctor or family member directly.';
  static const resultCallDialogOk = 'OK';
  static const resultTellMore = 'Tell me more';
  static const resultHideDetails = 'Hide details';
  static const resultDataLabel = 'Data last updated: ';
  static const resultSourceLabel = 'Source: ';
  static const resultAffectedLabel = 'Affected medicines: ';
  static const resultDone = 'Done';
  static const resultInteractionHeading = 'Interaction';
  static const resultDuplicateHeading = 'Duplicate ingredient';
  static const resultUncheckedHeading = 'Could not check';

  // ── Status words (colour + icon + word — always all three) ───────────
  static const statusGreen = 'No known problem found';
  static const statusYellow = 'Ask your doctor';
  static const statusRed =
      'Do not take together without asking your doctor';
  static const statusGrey = 'Could not check';

  // ── Generic ───────────────────────────────────────────────────────────
  static const back = 'Back';
  static const ok = 'OK';
  static const cancel = 'Cancel';
  static const loading = 'Checking your medicines…';
  static const errorGeneric =
      'Something went wrong. Please try again.';
}
