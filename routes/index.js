const express = require('express');
const router = express.Router();

router.use('/auth', require('./auth'));
router.use('/institution', require('./institutions'));
router.use('/certificates', require('./certificates'));
router.use('/certificates/:id/subjects', require('./subjects'));
router.use('/verify', require('./verify'));
router.use('/audit', require('./audit'));
router.use('/ai', require('./ai'));
router.use('/hash', require('./hash'));
router.use('/alerts', require('./alerts'));

module.exports = router;