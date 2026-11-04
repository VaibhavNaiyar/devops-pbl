const app = require('./app');
const port = process.env.PORT || 8080;
const server = app.listen(port, () => console.log(`patient-api on ${port}`));
process.on('SIGTERM', () => server.close(() => process.exit(0)));
