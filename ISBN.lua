local p = {}
local priv = {} -- private functions scope
-- expose private for easy testing/debugging
p.__priv = priv

local resources = {
	classLink = "isbn",
	classIncorrect = "isbn-incorrect",
	classSeparator = "isbn-do-sprawdzenia",
	classJustified = "isbn-usprawiedliwiony",
	classPretty = "isbn-ulepszony",
	specialBooksPrefix = "Specjalna:Książki/",
	isbnPrefix = "ISBN&#160;",
	categoryIncorrectNumber = "[[Kategoria:Artykuły z nieprawidłowymi numerami ISBN]]", -- nie-uspraw.
	categoryInvalidNumber = "[[Kategoria:Artykuły z błędnymi numerami ISBN]]", -- usprawiedliwiony
	errorSyntax = "nieprawidłowa składnia",
	errorFormal = "numer jest poprawny, możliwe, że ten sam numer jest przypisany do kilku różnych tytułów",
	errorCheck10 = "nieprawidłowa cyfra kontrolna w numerze ISBN-10",
	errorCheck13 = "nieprawidłowa cyfra kontrolna w numerze ISBN-13",
	errorPretend13 = "numer ISBN-13 zawiera niewłaściwe cyfry na kluczowych pozycjach",
	defaultPrefix13 = "978-",
}

-- Założenie jest takie, że jeśli istnieje wpis w goodInvalidIsbn,
-- to numer jest uznawany z prawidłowy mimo nieprawidłowej sumy kontrolnej itp
-- (czyli błąd jest usprawiedliwiony)
function priv.isGoodInvalidIsbn(isbn)
	return mw.loadData('Moduł:ISBN/usprawiedliwiony')[isbn]
		or false
end

function priv.deduceSeparators(number, prefix)

	local function deduce(region, regionLen)
		for _, v in ipairs(region) do
			local minimum, maximum = string.match(v, "^(%d-)%-(%d-)$")
			if minimum and maximum and #minimum==#maximum and (minimum <= maximum) then
				local width = #minimum
				local minimum = tonumber(minimum)
				local maximum = tonumber(maximum)
				local publisher = tonumber(string.sub(number, regionLen+1, regionLen+width))
				if (minimum <= publisher) and (publisher <= maximum) then
					return string.sub(number, 1, regionLen).."-"..string.sub(number, regionLen+1, regionLen+width).."-"..string.sub(number, regionLen+width+1)
				end
			end
		end
	end
	
	local publishers = mw.loadData( "Moduł:ISBN/wydawcy" )

	local regionLen = 1
	while regionLen <= 5 do
		local region = publishers[(prefix or resources.defaultPrefix13)..string.sub(number, 1, regionLen)]
		if region then
			local pretty = deduce(region, regionLen)
			if pretty then
				return pretty
			end
		end
		
		regionLen = regionLen + 1
	end
	
	if prefix and (prefix ~= defaultPrefix13) then
		regionLen = 1
		while regionLen <= 5 do
			region = publishers["978-"..string.sub(number, 1, regionLen)]
			if region then
				local pretty = deduce(region, regionLen)
				if pretty then
					return pretty
				end
			end
			
			regionLen = regionLen + 1
		end
	end
end

function priv.analyze(isbn)
	local result = {}
	
	result.isbn = isbn
	-- na początek sprawdzamy czy numer ma odpowiednie znaki (nie przejmujmy się długością)
	-- `result.code` będzie zawierać oczyszczony numer (bez kresek)
	if string.match(isbn, "^[0-9][0-9%-]+[0-9]%-?[0-9Xx]$") and not string.match(isbn, "%-%-") then
		local clean, n = string.gsub(isbn, "%-", "")
		result.code, result.n = string.upper(clean), n
	end
	
	if result.code and string.match(result.code, "^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9X]$") then
		-- ISBN-10
		local b10, b9, b8, b7, b6, b5, b4, b3, b2, b1 = string.byte(result.code, 1, 10)
		result.expectedSum = (11 - ((10*(b10-48)+9*(b9-48)+8*(b8-48)+7*(b7-48)+6*(b6-48)+5*(b5-48)+4*(b4-48)+3*(b3-48)+2*(b2-48)) % 11)) % 11
		result.receivedSum = b1 == 88 and 10 or (b1 - 48)
		result.kind = 10
		result.error = result.expectedSum ~= result.receivedSum and resources.errorCheck10 or nil
		result.separatorWarn = (result.n~=0) and ((result.n~=3) or not string.match(isbn, "[0-9]%-[0-9Xx]$"))
		result.prefix = false
		result.number = string.sub(result.code, 1, 9)
		result.checksum = "-"..string.sub(result.code, 10, 10)
	elseif result.code and (string.match(result.code, "^978[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$") or string.match(result.code, "^979[1-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$")) then
		-- ISBN-13
		local b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13 = string.byte(result.code, 1, 13)
		result.expectedSum = (10 - (((b1-48)+3*(b2-48)+(b3-48)+3*(b4-48)+(b5-48)+3*(b6-48)+(b7-48)+3*(b8-48)+(b9-48)+3*(b10-48)+(b11-48)+3*(b12-48)) % 10)) % 10
		result.receivedSum = b13 - 48
		result.kind = 13
		result.error = result.expectedSum ~= result.receivedSum and resources.errorCheck13 or nil
		result.separatorWarn = (result.n~=0) and ((result.n~=4) or not string.match(isbn, "^97[89]%-[0-9][0-9%-]-[0-9]%-[0-9]$"))
		result.prefix = string.sub(result.code, 1, 3).."-"
		result.number = string.sub(result.code, 4, 12)
		result.checksum = "-"..string.sub(result.code, 13, 13)
	elseif result.code and string.match(result.code, "^9[78][78][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9X]$") then
		-- ten numer udaje, że jest ISBN-13
		result.error = resources.errorPretend13
	else
		-- to nie jest numer ISBN, ma nieprawidłową liczbę cyfr lub nieprawidłowe znaki
		result.error = resources.errorSyntax
	end

	-- błędny, ale uznawany za poprawny?
	if result.code and result.error then
		result.justified = priv.isGoodInvalidIsbn(result.code)
	end

	if not result.error and (result.n == 0) and (result.prefix ~= nil) and result.checksum and result.number then
		local prettyNumber = priv.deduceSeparators(result.number, result.prefix)
		if prettyNumber then
			result.org = result.isbn
			result.isbn = (result.prefix or "")..prettyNumber..result.checksum
		end
	end

	return result
end

function priv.printISBN(builder, info, prefix)

	local ns = mw.title.getCurrentTitle().namespace
	
	if info.error and not info.justified and not mw.site.namespaces[ns].isTalk and (ns >= 0) and (ns <= 102) then
		mw.addWarning(mw.text.nowiki("{{ISBN|"..info.isbn.."}} "..info.error))
	end
	
	if not info.code then
		builder
			:wikitext(prefix)
			:tag("span")
				:addClass(resources.classIncorrect)
				:attr("title", mw.getContentLanguage():ucfirst(info.error))
				:wikitext(mw.text.nowiki(info.isbn), ns == 0 and resources.categoryIncorrectNumber or "")
		return
	end
	
	builder
		:wikitext("[[", resources.specialBooksPrefix, info.code, "|", prefix)
		:tag("span")
			:addClass(resources.classLink)
			:addClass(info.justified and resources.classJustified or nil)
			:addClass((not info.justified and info.error) and resources.classIncorrect or nil)
			:addClass(info.separatorWarn and resources.classSeparator or nil)
			:addClass(info.org and resources.classPretty or nil)
			:attr("title", info.error and mw.getContentLanguage():ucfirst(info.error) or nil)
			:wikitext(string.upper(info.isbn))
			:done()
		:wikitext("]]")
		:wikitext((not info.justified and info.error and (ns == 0)) and resources.categoryIncorrectNumber or "")
		:wikitext((info.justified and (ns == 0)) and resources.categoryInvalidNumber or "")
end

-- moduły wywołują: builder[html], link[string]
-- szablony wywołują: builder=frame
p.link = function(builder, isbn)
	if isbn then
		local info = priv.analyze(isbn)
		priv.printISBN(builder, info, resources.isbnPrefix)
		return tostring(builder)
	end
	
	local isbn = builder[1] or builder.args[1] or builder:getParent().args[1]
	if isbn then
		isbn = mw.text.trim(isbn)
		if #isbn >= 0 then
			local info = priv.analyze(isbn)
			local builder = mw.html.create()
			priv.printISBN(builder, info, resources.isbnPrefix)
			return tostring(builder)
		end
	end
end

p.opis = function(frame)
	local isbn = type(frame) == "string" and frame or (frame[1] or frame.args[1] or frame:getParent().args[1] or mw.title.getCurrentTitle().subpageText)
	local info = priv.analyze(isbn)
	local result = mw.html.create()
		:tag("tt"):wikitext("{{[[Szablon:ISBN|ISBN]]|", mw.text.nowiki(isbn), "}}"):done()
		:wikitext(" → ")
	priv.printISBN(result, info, resources.isbnPrefix)
	if info.error then
		result:wikitext("\n* ", mw.getContentLanguage():ucfirst(info.error), ".")
	end
	
	return tostring(result)
end

return p
