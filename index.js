var _param = require('./param.json');
var _redis = require('redis');

var _client = _redis.createClient(_param.port, _param.host);
_client.auth(_param.password);

_client.on('error', function (err) {
	console.error('Unexpected error: ' + err.toString());
});

var _pollInterval = _param.pollInterval;

var _accum = {};

function accum(vals, name)
{
	var last = _accum[name];
	var cur = vals[name];

	if (last === undefined)
		last = cur;

	var diff = cur - last;

	_accum[name] = cur;

	return diff;
}

function poll()
{
	_client.info(function(err, data)
	{
		if (err)
			return console.error(err);

		// Parse
		var lines = data.split('\n');
		var vals = {};

		lines.forEach(function(line)
		{
			var parts = line.split(':');
			if (parts.length == 2)
			{
				vals[parts[0]] = parts[1];
			}
		});

		// Report
		console.log('REDIS_CLIENTS %d', vals.connected_clients);
		console.log('REDIS_KEY_HITS %d', accum(vals, 'keyspace_hits'));
		console.log('REDIS_KEY_MISSES %d', accum(vals, 'keyspace_misses'));
		console.log('REDIS_KEYS_EXPIRED %d', accum(vals, 'expired_keys'));
		console.log('REDIS_KEYS_EVICTED %d', accum(vals, 'evicted_keys'));
		console.log('REDIS_COMMANDS_PROCESSED %d', accum(vals, 'total_commands_processed'));
		console.log('REDIS_CONNECTIONS_RECEIVED %d', accum(vals, 'total_connections_received'));
		console.log('REDIS_MEMORY_USED %d', vals.used_memory_rss);
	});

	setTimeout(poll, _pollInterval);
}

poll();