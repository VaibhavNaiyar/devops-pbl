const app = require('./app');
const port = process.env.PORT || 3000;
const server = app.listen(port, () => console.log(`listening on ${port}`));
// graceful shutdown -> zero-downtime rolling updates
process.on('SIGTERM', () => server.close(() => process.exit(0)));
