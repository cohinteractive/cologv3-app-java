package colog;

public class TagFilter {
    private static String activeTag = null;
    private static Runnable onFilterChanged;

    public static void setFilterListener(Runnable listener) {
        onFilterChanged = listener;
    }

    public static void setActiveTag(String tag) {
        activeTag = tag;
        if (onFilterChanged != null) onFilterChanged.run();
    }

    public static String getActiveTag() {
        return activeTag;
    }

    public static boolean matches(Exchange ex) {
        return activeTag == null || ex.tags.contains(activeTag);
    }

    public static void clear() {
        activeTag = null;
        if (onFilterChanged != null) onFilterChanged.run();
    }
}
