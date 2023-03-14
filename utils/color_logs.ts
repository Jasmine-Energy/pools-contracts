/**
 * @dev Convenience enum for log colours
 */
enum LogColours {
  blue = "'\x1b[36m%s\x1b[0m',",
}

function colouredLog(colour: LogColours, text: string) {
  console.log(colour, text);
}

export { LogColours, colouredLog };
