using Gee;
using Gtk;

using Dino.Entities;
using Xmpp;

namespace Dino.Ui.ConversationSummary {

class DateSeparatorPopulator : Plugins.ConversationItemPopulator, Plugins.ConversationAdditionPopulator, Object {

    public string id { get { return "date_separator"; } }

    private StreamInteractor stream_interactor;
    private Conversation? current_conversation;
    private Plugins.ConversationItemCollection? item_collection;
    private Gee.TreeSet<DateTime> insert_times;


    public DateSeparatorPopulator(StreamInteractor stream_interactor) {
        this.stream_interactor = stream_interactor;
    }

    public void init(Conversation conversation, Plugins.ConversationItemCollection item_collection, Plugins.WidgetType type) {
        current_conversation = conversation;
        this.item_collection = item_collection;
        item_collection.inserted_item.connect(on_inserted_item);
        this.insert_times = new TreeSet<DateTime>((a, b) => {
            return a.compare(b);
        });
    }

    public void close(Conversation conversation) {
        item_collection.inserted_item.disconnect(on_inserted_item);
    }

    public void populate_timespan(Conversation conversation, DateTime after, DateTime before) { }

    private void on_inserted_item(Plugins.MetaConversationItem item) {
        if (!(item is ContentMetaItem)) return;

        DateTime time = item.time.to_local();
        DateTime msg_date = new DateTime.local(time.get_year(), time.get_month(), time.get_day_of_month(), 0, 0, 0);
        if (!insert_times.contains(msg_date)) {
            if (insert_times.lower(msg_date) != null) {
                item_collection.insert_item(new MetaDateItem(msg_date.to_utc()));
            } else if (insert_times.size > 0) {
                item_collection.insert_item(new MetaDateItem(insert_times.first().to_utc()));
            }
            insert_times.add(msg_date);
        }
    }
}

public class MetaDateItem : Plugins.MetaConversationItem {
    public override DateTime time { get; set; }

    private DateTime date;

    public MetaDateItem(DateTime date) {
        this.date = date;
        this.time = date;
    }

    public override Object? get_widget(Plugins.ConversationItemWidgetInterface outer, Plugins.WidgetType widget_type) {
        return new DateSeparatorWidget(date);
    }

    public override Gee.List<Plugins.MessageAction>? get_item_actions(Plugins.WidgetType type) { return null; }


}

public class DateSeparatorWidget : Box {

    private DateTime date;
    private Label label;
    private uint time_update_timeout = 0;

    public DateSeparatorWidget(DateTime date) {
        Object(orientation:Orientation.HORIZONTAL, spacing:10);
        width_request = 300;
        halign = Align.CENTER;
        visible = true;
        this.date = date;

        label = new Label("") { use_markup=true, halign=Align.CENTER, hexpand=false };
        label.add_css_class("dim-label");

        this.append(new Separator(Orientation.HORIZONTAL) { valign=Align.CENTER, hexpand=true });
        this.append(label);
        this.append(new Separator(Orientation.HORIZONTAL) { valign=Align.CENTER, hexpand=true });

        update_time();
    }

    private void update_time() {
        label.label = @"<span size='small'>$(get_relative_time(date))</span>";
        time_update_timeout = Timeout.add_seconds((int) get_next_time_change(), () => {
            if (this.parent == null) return false;
            update_time();
            return false;
        });
    }

    private static string get_relative_time(DateTime time) {
        DateTime time_local = time.to_local();
        DateTime now_local = new DateTime.now_local();
        if (time_local.get_year() == now_local.get_year() &&
                time_local.get_month() == now_local.get_month() &&
                time_local.get_day_of_month() == now_local.get_day_of_month()) {
            return _("Today");
        }
        DateTime now_local_minus = now_local.add_days(-1);
        if (time_local.get_year() == now_local_minus.get_year() &&
                time_local.get_month() == now_local_minus.get_month() &&
                time_local.get_day_of_month() == now_local_minus.get_day_of_month()) {
            return _("Yesterday");
        }
        if (time_local.get_year() != now_local.get_year()) {
            return time_local.format("%x");
        }
        TimeSpan timespan = now_local.difference(time_local);
        if (timespan < 7 * TimeSpan.DAY) {
            return time_local.format(_("%a, %b %d"));
        } else {
            return time_local.format(_("%b %d"));
        }
    }

    private int get_next_time_change() {
        DateTime now = new DateTime.now_local();
        return (23 - now.get_hour()) * 3600 + (59 - now.get_minute()) * 60 + (59 - now.get_second()) + 1;
    }

    public override void dispose() {
        base.dispose();

        if (time_update_timeout != 0) {
            Source.remove(time_update_timeout);
            time_update_timeout = 0;
        }
    }
}

}
