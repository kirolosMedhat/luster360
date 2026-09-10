export type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';

class Logger {
  private formatMessage(level: LogLevel, message: string, meta?: any): string {
    const timestamp = new Date().toISOString();
    let metaStr = '';
    if (meta) {
      // Sanitize secrets from logs
      const sanitized = { ...meta };
      delete sanitized.password;
      delete sanitized.token;
      delete sanitized.secret;
      delete sanitized.serviceRoleKey;
      delete sanitized.refreshToken;
      metaStr = ` | ${JSON.stringify(sanitized)}`;
    }
    return `[${timestamp}] [${level}] ${message}${metaStr}`;
  }

  debug(message: string, meta?: any) {
    if (process.env.NODE_ENV !== 'production') {
      console.debug(this.formatMessage('DEBUG', message, meta));
    }
  }

  info(message: string, meta?: any) {
    console.info(this.formatMessage('INFO', message, meta));
  }

  warn(message: string, meta?: any) {
    console.warn(this.formatMessage('WARN', message, meta));
  }

  error(message: string, meta?: any) {
    console.error(this.formatMessage('ERROR', message, meta));
  }
}

export const logger = new Logger();
