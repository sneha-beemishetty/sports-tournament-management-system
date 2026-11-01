require('dotenv').config();
const bcrypt = require('bcrypt');
const db = require('../config/db');
(async () => {
  const username = process.argv[2];
  const password = process.argv[3];
  if (!username || !password || password.length < 10) {
    console.error('Usage: npm run admin:create -- <username> <password-at-least-10-characters>');
    process.exitCode = 1; return;
  }
  try {
    const hash = await bcrypt.hash(password, 12);
    await db.execute('INSERT INTO admins(username,password_hash) VALUES (?,?) ON DUPLICATE KEY UPDATE password_hash=VALUES(password_hash)', [username, hash]);
    console.log(`Admin account '${username}' is ready.`);
  } catch (error) { console.error('Could not create admin. Check the database configuration and schema.'); process.exitCode = 1; }
  finally { await db.end(); }
})();
