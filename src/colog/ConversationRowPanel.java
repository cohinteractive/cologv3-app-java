package colog;

import javax.swing.*;
import java.awt.*;
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
    private final JLabel titleLabel;
    private final JLabel tagLabel;

    public ConversationRowPanel(int index, Conversation conversation) {
        this.index = index;
        this.conversation = conversation;

        setLayout(new BoxLayout(this, BoxLayout.X_AXIS));
        setOpaque(true);

        Font font = getFont();
        int fontHeight = getFontMetrics(font).getHeight();

        idLabel = createLabel("#" + index, 40, SwingConstants.LEFT, fontHeight);
        timeLabel = createLabel(formatTimestamp(conversation), 110, SwingConstants.LEFT, fontHeight);
        titleLabel = createLabel(conversation.title, 240, SwingConstants.LEFT, fontHeight);
        tagLabel = createLabel(buildTagSummary(conversation), 100, SwingConstants.RIGHT, fontHeight);

        add(idLabel);
        add(timeLabel);
        add(titleLabel);
        add(Box.createHorizontalGlue());
        add(tagLabel);

        setPreferredSize(new Dimension(Short.MAX_VALUE, fontHeight));

        addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                Main.selectConversation(conversation);
            }
        });
    }

    private JLabel createLabel(String text, int width, int align, int height) {
        JLabel l = new JLabel(text);
        l.setHorizontalAlignment(align);
        Dimension d = new Dimension(width, height);
        l.setPreferredSize(d);
        l.setMaximumSize(d);
        l.setMinimumSize(d);
        return l;
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
        setBackground(selected ? new Color(220, 220, 250) : null);
    }
}
