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
        int rowHeight = fm.getHeight();

        idLabel = createLabel("#" + index, 40, SwingConstants.LEFT, rowHeight);
        countLabel = createLabel(Integer.toString(conversation.exchanges.size()), 60, SwingConstants.LEFT, rowHeight);
        timeLabel = createLabel(formatTimestamp(conversation), 140, SwingConstants.LEFT, rowHeight);
        titleLabel = createLabel(conversation.title, 300, SwingConstants.LEFT, rowHeight);
        tagLabel = createLabel(buildTagSummary(conversation), 200, SwingConstants.RIGHT, rowHeight);

        row = new JPanel();
        row.setLayout(new BoxLayout(row, BoxLayout.X_AXIS));
        row.setOpaque(true);
        row.setBackground(DARK_BG);
        row.setAlignmentX(LEFT_ALIGNMENT);

        row.add(createCell(idLabel, 40, rowHeight));
        row.add(createVLine(rowHeight));
        row.add(createCell(countLabel, 60, rowHeight));
        row.add(createVLine(rowHeight));
        row.add(createCell(timeLabel, 140, rowHeight));
        row.add(createVLine(rowHeight));
        row.add(createCell(titleLabel, 300, rowHeight));
        row.add(createVLine(rowHeight));
        row.add(createCell(tagLabel, 200, rowHeight));

        row.setPreferredSize(new Dimension(Short.MAX_VALUE, rowHeight));
        row.setMaximumSize(new Dimension(Short.MAX_VALUE, rowHeight));
        add(row);

        JSeparator hLine = new JSeparator(SwingConstants.HORIZONTAL);
        hLine.setForeground(new Color(60, 60, 60));
        add(hLine);

        setPreferredSize(new Dimension(Short.MAX_VALUE, rowHeight + 1));

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
        l.setBorder(BorderFactory.createLineBorder(Color.GRAY));
        l.setForeground(LIGHT_TEXT);
        l.setBackground(DARK_BG);
        l.setOpaque(true);
        return l;
    }

    private JPanel createCell(JLabel label, int width, int height) {
        JPanel cell = new JPanel();
        cell.setLayout(new BoxLayout(cell, BoxLayout.X_AXIS));
        cell.setOpaque(false);
        Dimension d = new Dimension(width, height);
        cell.setPreferredSize(d);
        cell.setMaximumSize(d);
        cell.setMinimumSize(d);
        cell.add(label);
        return cell;
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
