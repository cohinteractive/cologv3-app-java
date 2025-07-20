package colog;

import javax.swing.*;
import javax.swing.border.EmptyBorder;
import java.awt.*;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import static colog.Theme.*;
import static colog.UIStyle.*;

/**
 * A single exchange row with timestamp, summary, tags, and expandable prompt/response text.
 */
public class ExchangePanel extends JPanel {

    private final String promptText;
    private final String responseText;
    private final String timestamp;
    private final java.util.List<String> tags;

    private final JLabel expandLabel;
    private final JLabel timestampLabel;
    private boolean isExpanded = false;
    private Exchange exchange;

    public ExchangePanel(Exchange ex) {
        this(ex.timestamp, ex.prompt, ex.response, ex.tags);
        this.exchange = ex;
        this.isExpanded = ex.isExpanded;
        updateLayout();
    }

    private ExchangePanel(String timestamp, String prompt, String response, java.util.List<String> tagsList) {
        this.timestamp = timestamp;
        this.promptText = prompt == null ? "" : prompt.replace("\\n", "\n");
        this.responseText = response == null ? "" : response.replace("\\n", "\n");
        this.tags = new java.util.ArrayList<>(tagsList);
        this.exchange = null;

        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setBackground(DARK_BG);
        setBorder(BorderFactory.createEmptyBorder(0, 0, 0, 0));

        expandLabel = new JLabel("\u2BC8");
        expandLabel.setFont(BASE_FONT);
        expandLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        expandLabel.setForeground(LIGHT_TEXT);
        expandLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
        expandLabel.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent e) {
                toggleExpanded();
            }
        });

        timestampLabel = new JLabel(timestamp);
        timestampLabel.setFont(BASE_FONT);
        timestampLabel.setBorder(BorderFactory.createEmptyBorder(0, 5, 0, 5));
        timestampLabel.setForeground(LIGHT_TEXT);

        updateLayout();
    }

    private JTextArea createArea(String text) {
        if (text == null) text = "";
        text = text.replace("\\n", "\n");
        JTextArea area = new JTextArea(text);
        area.setFont(BASE_FONT);
        area.setLineWrap(true);
        area.setWrapStyleWord(true);
        area.setOpaque(true);
        area.setBackground(DARK_BG);
        area.setForeground(LIGHT_TEXT);
        area.setEditable(false);
        area.setFocusable(false);
        area.setBorder(null);
        area.setMargin(new Insets(0, 0, 0, 0));
        area.setAlignmentX(LEFT_ALIGNMENT);
        return area;
    }

    private JPanel buildSection(String labelText, String text, JTextArea area,
                                Color bg, Color fg, boolean indent) {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.Y_AXIS));
        panel.setBackground(bg);
        panel.setOpaque(true);
        panel.setAlignmentX(LEFT_ALIGNMENT);
        panel.setBorder(new EmptyBorder(4, 0, 4, 0));

        JPanel wrapper = new JPanel();
        wrapper.setLayout(new BoxLayout(wrapper, BoxLayout.Y_AXIS));
        wrapper.setBorder(BorderFactory.createEmptyBorder(0, indent ? 15 : 0, 0, 0));
        wrapper.setOpaque(false);

        JLabel label = new JLabel(labelText);
        label.setFont(BASE_FONT.deriveFont(Font.BOLD));
        label.setForeground(fg);
        label.setBackground(bg);
        label.setOpaque(true);
        wrapper.add(label);

        JLabel summaryLabel = new JLabel("Summary: " + summarize(text));
        summaryLabel.setFont(BASE_FONT.deriveFont(Font.ITALIC, BASE_FONT.getSize2D() - 1f));
        summaryLabel.setForeground(fg);
        summaryLabel.setBackground(bg);
        summaryLabel.setOpaque(true);
        summaryLabel.setMaximumSize(new Dimension(Integer.MAX_VALUE, summaryLabel.getPreferredSize().height));
        wrapper.add(summaryLabel);

        wrapper.add(new JSeparator(SwingConstants.HORIZONTAL));

        area.setForeground(fg);
        area.setBackground(bg);
        wrapper.add(area);

        panel.add(wrapper);

        return panel;
    }

    private static String summarize(String text) {
        if (text == null) return "";
        String summary = text.replaceAll("\\s+", " ").strip();
        if (summary.length() > 80) summary = summary.substring(0, 80) + "…";
        return summary;
    }

    private JPanel buildTagPanel() {
        JPanel tagPanel = new JPanel(new FlowLayout(FlowLayout.LEFT, 4, 0));
        tagPanel.setOpaque(false);
        for (String tag : tags) {
            final String t = tag;
            JLabel tagLabel = new JLabel("#" + tag);
            tagLabel.setFont(BASE_FONT);
            tagLabel.setForeground(LIGHT_TEXT);
            tagLabel.setBackground(TAG_BG);
            tagLabel.setOpaque(true);
            tagLabel.setBorder(new EmptyBorder(0, 4, 0, 4));
            tagLabel.setCursor(Cursor.getPredefinedCursor(Cursor.HAND_CURSOR));
            tagLabel.setToolTipText("Click to filter by #" + tag);
            tagLabel.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(MouseEvent e) {
                    TagFilter.setActiveTag(t);
                }

                @Override
                public void mouseEntered(MouseEvent e) {
                    tagLabel.setFont(tagLabel.getFont().deriveFont(Font.BOLD));
                }

                @Override
                public void mouseExited(MouseEvent e) {
                    tagLabel.setFont(tagLabel.getFont().deriveFont(Font.PLAIN));
                }
            });
            tagPanel.add(tagLabel);
        }
        return tagPanel;
    }

    private void updateLayout() {
        removeAll();

        expandLabel.setText(isExpanded ? "\u2BC6" : "\u2BC8");

        JPanel topRow = new JPanel(new FlowLayout(FlowLayout.LEFT, 6, 0));
        topRow.setOpaque(false);
        topRow.add(expandLabel);
        topRow.add(timestampLabel);
        topRow.setAlignmentX(LEFT_ALIGNMENT);
        add(topRow);

        JLabel summaryLabel = new JLabel(summarize(promptText));
        summaryLabel.setFont(BASE_FONT);
        summaryLabel.setForeground(LIGHT_TEXT);
        summaryLabel.setAlignmentX(LEFT_ALIGNMENT);
        add(summaryLabel);

        if (isExpanded) {
            add(buildSection("Prompt", promptText, createArea(promptText), PROMPT_BG, LIGHT_TEXT, false));
            add(Box.createVerticalStrut(8));
            add(buildSection("Response", responseText, createArea(responseText), RESPONSE_BG, LIGHT_TEXT, true));
            JPanel tagPanel = buildTagPanel();
            tagPanel.setAlignmentX(LEFT_ALIGNMENT);
            add(tagPanel);
        }

        FontMetrics fm = getFontMetrics(BASE_FONT);
        if (isExpanded) {
            setPreferredSize(null);
            setMaximumSize(new Dimension(Integer.MAX_VALUE, Integer.MAX_VALUE));
        } else {
            int height = fm.getHeight() * 2; // top row + summary
            Dimension d = new Dimension(Integer.MAX_VALUE, height);
            setPreferredSize(d);
            setMaximumSize(d);
        }

        revalidate();
        repaint();
    }

    private void toggleExpanded() {
        JScrollPane pane = (JScrollPane) SwingUtilities.getAncestorOfClass(JScrollPane.class, this);
        JScrollBar bar = pane == null ? null : pane.getVerticalScrollBar();
        int val = bar == null ? 0 : bar.getValue();

        isExpanded = !isExpanded;
        if (exchange != null) {
            exchange.isExpanded = isExpanded;
        }
        updateLayout();

        if (bar != null) {
            bar.setValue(val);
        }
    }

    /**
     * Expands this panel if collapsed and scrolls it into view.
     */
    public void expandAndFocus() {
        if (!isExpanded) {
            toggleExpanded();
        }
        scrollRectToVisible(getBounds());
    }
}
