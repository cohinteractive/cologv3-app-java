package colog;

import javax.swing.*;
import java.awt.*;
import static colog.Theme.*;
import static colog.UIStyle.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.LinkedHashSet;
import java.util.Set;

/**
 * Compact row representing a conversation in the sidebar.
 */
public class ConversationRowPanel extends JPanel {
    // Simple row click handling now directly notifies Main

    private static final DateTimeFormatter IN_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    private static final DateTimeFormatter OUT_FMT = DateTimeFormatter.ofPattern("d/MM/yy H:mm:ss");

    private final int index;
    private final Conversation conversation;

    private final JLabel idLabel;
    private final JLabel timeLabel;
    private final JLabel countLabel;
    private final JLabel titleLabel;
    private final JLabel tagLabel;
    private final JPanel row;

    public ConversationRowPanel(int index, Conversation conversation) {
        this.index = index;
        this.conversation = conversation;

        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setOpaque(true);
        setBackground(DARK_BG);

        FontMetrics fm = getFontMetrics(BASE_FONT);
        int fontHeight = fm.getHeight();

        idLabel = createLabel("#" + index, 30, SwingConstants.LEFT, fontHeight);
        countLabel = createLabel("\u00D7" + conversation.exchanges.size(), 40, SwingConstants.RIGHT, fontHeight);
        timeLabel = createLabel(formatTimestamp(conversation), 110, SwingConstants.LEFT, fontHeight);
        titleLabel = createLabel(conversation.title, 240, SwingConstants.LEFT, fontHeight);
        tagLabel = createLabel(buildTagSummary(conversation), 100, SwingConstants.RIGHT, fontHeight);

        row = new JPanel();
        row.setLayout(new BoxLayout(row, BoxLayout.X_AXIS));
        row.setOpaque(true);
        row.setBackground(DARK_BG);

        row.add(idLabel);
        row.add(createVLine(fontHeight));
        row.add(countLabel);
        row.add(createVLine(fontHeight));
        row.add(timeLabel);
        row.add(createVLine(fontHeight));
        row.add(titleLabel);
        row.add(createVLine(fontHeight));
        row.add(Box.createHorizontalGlue());
        row.add(tagLabel);

        row.setPreferredSize(new Dimension(Short.MAX_VALUE, fontHeight));
        add(row);

        JSeparator hLine = new JSeparator(SwingConstants.HORIZONTAL);
        hLine.setForeground(new Color(60, 60, 60));
        add(hLine);

        setPreferredSize(new Dimension(Short.MAX_VALUE, fontHeight + 1));

        addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                Main.selectConversation(conversation);
            }
        });
    }

    private JLabel createLabel(String text, int width, int align, int height) {
        JLabel l = new JLabel(text);
        l.setFont(BASE_FONT);
        l.setHorizontalAlignment(align);
        Dimension d = new Dimension(width, height);
        l.setPreferredSize(d);
        l.setMaximumSize(d);
        l.setMinimumSize(d);
        l.setForeground(LIGHT_TEXT);
        l.setBackground(DARK_BG);
        l.setOpaque(true);
        return l;
    }

    private JSeparator createVLine(int height) {
        JSeparator vLine = new JSeparator(SwingConstants.VERTICAL);
        vLine.setPreferredSize(new Dimension(1, height));
        vLine.setForeground(new Color(60, 60, 60));
        return vLine;
    }

    private static String formatTimestamp(Conversation conversation) {
        if (conversation.exchanges.isEmpty()) return "";
        String ts = conversation.exchanges.get(0).timestamp;
        try {
            LocalDateTime t = LocalDateTime.parse(ts, IN_FMT);
            return OUT_FMT.format(t);
        } catch (DateTimeParseException ex) {
            return ts;
        }
    }

    private static String buildTagSummary(Conversation conversation) {
        Set<String> tags = new LinkedHashSet<>();
        for (Exchange ex : conversation.exchanges) {
            tags.addAll(ex.tags);
        }
        StringBuilder sb = new StringBuilder();
        for (String t : tags) {
            sb.append('[').append(t.toUpperCase()).append(']');
        }
        return sb.toString();
    }

    public void setSelected(boolean selected) {
        Color bg = selected ? new Color(50, 50, 80) : DARK_BG;
        setBackground(bg);
        row.setBackground(bg);
    }
}
