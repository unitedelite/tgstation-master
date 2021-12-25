import { CheckboxInput, FeatureColorInput, Feature, FeatureDropdownInput, FeatureToggle } from "../base";

export const asaycolor: Feature<string> = {
  name: "Admin chat color",
  category: "ADMIN",
  description: "The color of your messages in Adminsay.",
  component: FeatureColorInput,
};

export const brief_outfit: Feature<string> = {
  name: "Brief outfit",
  category: "ADMIN",
  description: "The outfit to gain when spawning as the briefing officer.",
  component: FeatureDropdownInput,
};

export const bypass_deadmin_in_centcom: FeatureToggle = {
  name: "Bypass deadmin options when in CentCom",
  category: "ADMIN",
  description: "Whether or not to always remain an admin when spawned in CentCom.",
  component: CheckboxInput,
};

//From Skyrat-tg/tgui/packages/tgui/interfaces/PreferencesMenu/preferences/features/game_preferences/skyrat/looc.tsx  BEGIN 
export const looc_admin_pref: FeatureToggle = {
  name: "See admin LOOC",
  category: "ADMIN",
  description: "Toggles whether you want to see LOOC anywhere as an admin or not.",
  component: CheckboxInput,
};
//SKYRAT END