
export const disableForking: boolean = (
    process.env.NO_FORK && 
    (process.env.NO_FORK.toLowerCase() === "true" || process.env.NO_FORK.toLowerCase() === "yes")
) ? true : false; // TODO: This is a bit of a pain...
