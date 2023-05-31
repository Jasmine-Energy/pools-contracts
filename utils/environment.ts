
export const disableForking: boolean = !!(process.env.NO_FORK?.toLowerCase?.() === "true" || process.env.NO_FORK === "yes");
