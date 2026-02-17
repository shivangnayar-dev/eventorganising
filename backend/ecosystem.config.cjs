module.exports = {
  apps: [
    {
      name: 'eventorganising-api-dev',
      script: './dist/server.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
      },
      // Note: Copy .env.development to .env before starting
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '500M',
      min_uptime: '10s',
      max_restarts: 10,
    },
    {
      name: 'eventorganising-api-prod',
      script: './dist/server.js',
      instances: 2, // Use 2 instances for better performance
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3001, // Different port from dev to run both simultaneously
      },
      // Note: Copy .env.production to .env before starting
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      min_uptime: '10s',
      max_restarts: 10,
      // Production optimizations
      node_args: '--max-old-space-size=1024',
    },
  ],
};

