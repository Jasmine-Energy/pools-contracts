
/**
 * @dev Convenience enum for log colors
 *
 * NOTE: See list of ANSI color codes [here.](https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124)
 */
enum LogColors {
  blue = "\x1b[36m%s\x1b[0m,",
  red = "\x1b[31m%s\x1b[0m,",
  green = "\x1b[32m%s\x1b[0m,",
  yellow = "\x1b[33m%s\x1b[0m,",
}

type LogColorKeys = keyof typeof LogColors;
/**
 * @dev Allows colored logging for any color in LogColors
 */
type KeyedColorLogger = {
  [key in LogColorKeys]: (text: string) => void;
};
/**
 * @dev Extends KeyedColorLogger by making it calleable per se
 * 
 * @example logger.red("Hello world!")
 * @example logger(LogColors.yellow, "Wow")
 */
interface ColorLogger extends KeyedColorLogger {
  (colour: LogColors, text: string): void;
}

const logger: KeyedColorLogger = <KeyedColorLogger>Object.fromEntries(
  (Object.keys(LogColors) as Array<keyof typeof LogColors>).map((colour) => {
    return [
      colour,
      (text: string) => {
        colouredLog(LogColors[colour], text);
      },
    ];
  })
);


const colouredLog: ColorLogger = <ColorLogger>((colour: LogColors, text: string) => {
  console.log(colour, text);
});

Object.assign(colouredLog, logger);
Object.setPrototypeOf(colouredLog, Object.getPrototypeOf(logger));

export { LogColors, colouredLog };
