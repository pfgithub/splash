const {parse, inverse} = require("scpl");

module.exports.parse = (stringToParse) => {
	let result;
	try{
		result = parse(stringToParse, {make: ["shortcutjson", "shortcutplist"]});
	}catch(e){
		return "Error!"
	}
	return result.shortcutplist.toString("base64");
}

module.exports.inverse = (base64ToInverse) => {
	let result;
	try{
		result = parse(Buffer.from(base64ToInverse, "base64"));
	}catch(e){
		return "Error!";
	}
	return result;
}

//module.exports = {parse, inverse};
