namespace Dino.Entities {

public class Settings : Object {

    private Database db;

    public Settings.from_db(Database db, bool default_dark_theme) {
        this.db = db;

        send_typing_ = col_to_bool_or_default("send_typing", true);
        send_marker_ = col_to_bool_or_default("send_marker", true);
        notifications_ = col_to_bool_or_default("notifications", true);
        convert_utf8_smileys_ = col_to_bool_or_default("convert_utf8_smileys", true);
        check_spelling = col_to_bool_or_default("check_spelling", true);
        default_encryption = col_to_encryption_or_default("default_encryption", Encryption.UNKNOWN);
        send_button = col_to_bool_or_default("send_button", false);
        enter_newline = col_to_bool_or_default("enter_newline", false);
        dark_theme = col_to_bool_or_default("dark_theme", default_dark_theme);
    }

    private bool col_to_bool_or_default(string key, bool def) {
        string? val = db.settings.select({db.settings.value}).with(db.settings.key, "=", key)[db.settings.value];
        return val != null ? bool.parse(val) : def;
    }

    private Encryption col_to_encryption_or_default(string key, Encryption def) {
        var sval = db.settings.value;
        string? val = db.settings.select({sval}).with(db.settings.key, "=", key)[sval];
        return val != null ? Encryption.parse(val) : def;
    }

    private bool send_typing_;
    public bool send_typing {
        get { return send_typing_; }
        set {
            db.settings.upsert()
                    .value(db.settings.key, "send_typing", true)
                    .value(db.settings.value, value.to_string())
                    .perform();
            send_typing_ = value;
        }
    }

    private bool send_marker_;
    public bool send_marker {
        get { return send_marker_; }
        set {
            db.settings.upsert()
                    .value(db.settings.key, "send_marker", true)
                    .value(db.settings.value, value.to_string())
                    .perform();
            send_marker_ = value;
        }
    }

    private bool notifications_;
    public bool notifications {
        get { return notifications_; }
        set {
            db.settings.upsert()
                    .value(db.settings.key, "notifications", true)
                    .value(db.settings.value, value.to_string())
                    .perform();
            notifications_ = value;
        }
    }

    private bool convert_utf8_smileys_;
    public bool convert_utf8_smileys {
        get { return convert_utf8_smileys_; }
        set {
            db.settings.upsert()
                    .value(db.settings.key, "convert_utf8_smileys", true)
                    .value(db.settings.value, value.to_string())
                    .perform();
            convert_utf8_smileys_ = value;
        }
    }

    // There is currently no spell checking for GTK4, thus there is currently no UI for this setting.
    private bool check_spelling_;
    public bool check_spelling {
        get { return check_spelling_; }
        set {
            db.settings.upsert()
                .value(db.settings.key, "check_spelling", true)
                .value(db.settings.value, value.to_string())
                .perform();
            check_spelling_ = value;
        }
    }

    private Encryption default_encryption_;
    public Encryption default_encryption {
        get { return default_encryption_; }
        set {
            string valstr = value.to_string();
            db.settings.upsert()
                .value(db.settings.key, "default_encryption", true)
                .value(db.settings.value, valstr)
                .perform();
            default_encryption_ = value;
        }
    }


    public signal void send_button_update(bool visible);
    private bool send_button_;
    public bool send_button {
        get { return send_button_; }
        set {
            db.settings.upsert()
                .value(db.settings.key, "send_button", true)
                .value(db.settings.value, value.to_string())
                .perform();
            send_button_ = value;
            send_button_update(value);
        }
    }

    private bool enter_newline_;
    public bool enter_newline {
        get { return enter_newline_; }
        set {
            db.settings.upsert()
                .value(db.settings.key, "enter_newline", true)
                .value(db.settings.value, value.to_string())
                .perform();
            enter_newline_ = value;
        }
    }

    public signal void dark_theme_update(bool is_dark);
    private bool dark_theme_;
    public bool dark_theme {
        get { return dark_theme_; }
        set {
            db.settings.upsert()
                .value(db.settings.key, "dark_theme", true)
                .value(db.settings.value, value.to_string())
                .perform();
            dark_theme_ = value;
            dark_theme_update(value);
        }
    }
}

}
