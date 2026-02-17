import winston from 'winston';
import { env } from './env.js';

const logFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.splat(),
  winston.format.json()
);

const consoleFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    let msg = `${timestamp} [${level}]: ${message}`;
    if (Object.keys(meta).length > 0) {
      msg += ` ${JSON.stringify(meta)}`;
    }
    return msg;
  })
);

export const logger = winston.createLogger({
  level: env.environment === 'production' ? 'info' : 'debug',
  format: logFormat,
  defaultMeta: { service: 'eventorganising-backend' },
  transports: [
    // Write all logs to console
    new winston.transports.Console({
      format: env.environment === 'production' ? logFormat : consoleFormat,
    }),
    // Write all logs with level `error` and below to `error.log`
    new winston.transports.File({
      filename: 'logs/error.log',
      level: 'error',
      format: logFormat,
    }),
    // Write all logs with level `info` and below to `combined.log`
    new winston.transports.File({
      filename: 'logs/combined.log',
      format: logFormat,
    }),
  ],
});

// If we're not in production, log to console with simpler format
if (env.environment !== 'production') {
  logger.add(
    new winston.transports.Console({
      format: consoleFormat,
    })
  );
}
