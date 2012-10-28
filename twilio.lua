local underscore = require('webscriptio/lib/underscore.lua')

local verify = function (request, authToken)
	local sts = request.scheme .. '://' .. request.headers.Host .. request.path
	for k in underscore.sort(underscore.keys(request.form)) do
		sts = sts .. k .. request.form[k]
	end

	hmac = crypto.hmac(authToken, sts, crypto.sha1).digest()
	return request.headers['X-Twilio-Signature'] == base64.encode(hmac)
end

local sms = function (accountsid, authtoken, from, to, body)
	return http.request {
		method = 'POST',
		url = string.format('https://api.twilio.com/2010-04-01/Accounts/%s/SMS/Messages.json', accountsid),
		data = { From=from, To=to, Body=body },
		auth = {accountsid, authtoken}
	}
end

local call = function (accountsid, authtoken, from, to, url)
	return http.request {
		method = 'POST',
		url = string.format('https://api.twilio.com/2010-04-01/Accounts/%s/Calls.json', accountsid),
		data={ From=from, To=to, Url=url },
		auth={accountsid, authtoken}
	}
end

return { verify = verify, sms = sms, call = call }