settings = new Store("settings", {})

chrome.extension.onRequest.addListener (request, sender, sendResponse) ->
	if (request.action == 'gpmeGetOptions')
		sendResponse(settings.toObject())
