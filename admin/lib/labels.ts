// Readable names for the codes the app records. Shared by the admin pages
// and the CSV exports.

export const OUTCOME: Record<string, string> = {
  ELIGIBLE: "Eligible, needs Form 6",
  MOVED_IN: "Moved in, needs Form 8",
  CORRECTION: "Needs a correction",
  ALREADY_ON_ROLL: "Already on the roll",
  SHIFTED: "Shifted away",
  DEAD: "Dead",
  NOT_MET: "Not met",
};

export const FORM_STATUS: Record<string, string> = {
  FILLED: "Filled, not submitted",
  SUBMITTED: "Submitted",
  IN_ERO_LIST: "In ERO list",
  HEARING: "Hearing",
  ACCEPTED: "Accepted",
  REJECTED: "Rejected",
};

export const ROUTE: Record<string, string> = { BLA2: "Through BLA-2", SELF: "By the voter", ONLINE: "Online" };

export const CATEGORY: Record<string, string> = {
  UNTRACEABLE: "Untraceable / absent",
  SHIFTED: "Permanently shifted",
  POSS_HIGH: "Possibly deleted: high",
  POSS_MEDIUM: "Possibly deleted: medium",
  POSS_LOW: "Possibly deleted: low (check first)",
  DECEASED: "Deceased (verify with family)",
  DUPLICATE: "Duplicate (check enrolment elsewhere)",
  ALREADY_BACK: "Already back on the roll (no visit)",
  ON_DRAFT_ROLL: "On the 17 Nov draft roll (no visit)",
  NEW: "Added in the field",
};

export const NEW_REASON: Record<string, string> = { TURNED_18_THIS_YEAR: "Turned 18 this year", OTHER: "Other" };

export const RELATION: Record<string, string> = { F: "Father", H: "Husband", M: "Mother", O: "Other" };

export const CONTACT_RELATION: Record<string, string> = {
  FATHER: "Father",
  MOTHER: "Mother",
  HUSBAND: "Husband",
  WIFE: "Wife",
  SON: "Son",
  DAUGHTER: "Daughter",
  SIBLING: "Brother / sister",
  SELF: "Self",
  OTHER: "Other",
};

export const GENDER: Record<string, string> = { M: "Male", F: "Female", O: "Other" };

export const DOC: Record<string, string> = {
  AADHAAR: "Aadhaar",
  BIRTH_CERT: "Birth certificate",
  HIGHSCHOOL: "High school marksheet",
  RATION: "Ration card",
  ELECTRICITY: "Electricity bill",
  OTHER: "Other",
};

export const FLAG: Record<string, string> = {
  GPS_OFF: "Location was off",
  GPS_DENIED: "Location permission refused",
  GPS_TIMEOUT: "No location fix in time",
  GPS_INACCURATE: "Location rough (over 100 m)",
  GPS_APPROXIMATE: "Only approximate location",
  CLOCK_SKEW: "Phone clock was wrong",
};

export function label(map: Record<string, string>, code: string | null | undefined): string {
  if (!code) return "";
  return map[code] ?? code;
}

/** "24 Nov, 10:42 am" in India time. */
export function istTime(iso: string | null | undefined): string {
  if (!iso) return "";
  return new Date(iso).toLocaleString("en-IN", {
    day: "numeric",
    month: "short",
    hour: "numeric",
    minute: "2-digit",
    timeZone: "Asia/Kolkata",
  });
}

/** Today in India as YYYY-MM-DD, shifted by whole days. */
export function istDate(offsetDays = 0): string {
  return new Date(Date.now() + 5.5 * 3600 * 1000 + offsetDays * 86400 * 1000).toISOString().slice(0, 10);
}
