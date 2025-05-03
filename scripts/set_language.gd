extends OptionButton

func _ready():
	self.selected = Globals.language

func _set_language(lang: int):
	Globals.language = lang
	TranslationServer.set_locale(Globals.languages[lang])
	Globals._save_settings()
