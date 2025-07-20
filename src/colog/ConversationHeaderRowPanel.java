package colog;

import javax.swing.*;
import java.awt.*;
import static colog.UIStyle.*;

/**
 * Header row for the conversation list columns.
 */
public class ConversationHeaderRowPanel extends JPanel {
    public ConversationHeaderRowPanel() {
        Color bg = new Color(40, 40, 40);
        Color fg = new Color(200, 200, 200);
        Font font = BASE_FONT.deriveFont(Font.BOLD);

        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setOpaque(true);
        setBackground(bg);

        FontMetrics fm = getFontMetrics(font);
        int fontHeight = fm.getHeight();

        JPanel row = new JPanel();
        row.setLayout(new BoxLayout(row, BoxLayout.X_AXIS));
        row.setOpaque(true);
        row.setBackground(bg);
        row.setAlignmentX(LEFT_ALIGNMENT);

        row.add(createCell("Index", 80, SwingConstants.LEFT, fontHeight, font, fg, bg));
        row.add(createVLine(fontHeight));
        row.add(createCell("Prompt Count", 120, SwingConstants.LEFT, fontHeight, font, fg, bg));
        row.add(createVLine(fontHeight));
        row.add(createCell("Date/Time", 140, SwingConstants.LEFT, fontHeight, font, fg, bg));
        row.add(createVLine(fontHeight));
        row.add(createCell("Conversation Title", 300, SwingConstants.LEFT, fontHeight, font, fg, bg));

        row.setPreferredSize(new Dimension(Short.MAX_VALUE, fontHeight));
        row.setMaximumSize(new Dimension(Short.MAX_VALUE, fontHeight));
        add(row);
        setPreferredSize(new Dimension(Short.MAX_VALUE, fontHeight + 1));
    }

    private JLabel createLabel(String text, int width, int align, int height, Font f, Color fg, Color bg) {
        JLabel l = new JLabel(text);
        l.setFont(f);
        l.setHorizontalAlignment(align);
        Dimension d = new Dimension(width, height);
        l.setPreferredSize(d);
        l.setMaximumSize(d);
        l.setMinimumSize(d);
        l.setBorder(BorderFactory.createLineBorder(Color.GRAY));
        l.setForeground(fg);
        l.setBackground(bg);
        l.setOpaque(true);
        return l;
    }

    private JPanel createCell(String text, int width, int align, int height, Font f, Color fg, Color bg) {
        JLabel label = createLabel(text, width, align, height, f, fg, bg);
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
}
