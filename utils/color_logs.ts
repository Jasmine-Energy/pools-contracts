/**
 * @dev Convenience enum for log colours
 * 
 * NOTE: See list of ANSI color codes [here.](https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124)
 */
enum LogColours {
  blue    = "\x1b[36m%s\x1b[0m,",
  red     = "\x1b[31m%s\x1b[0m,",
  green   = "\x1b[32m%s\x1b[0m,",
  yellow  = "\x1b[33m%s\x1b[0m,",
}

function colouredLog(colour: LogColours, text: string) {
  console.log(colour, text);
}

export { LogColours, colouredLog };
