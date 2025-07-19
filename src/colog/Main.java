package colog;

import javax.swing.*;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.awt.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import colog.TagFilter;


public class Main {
    private static File lastDir;
    private static JPanel container;
    private static JScrollPane scrollPane;
    private static JPanel summaryPanel;
    private static Map<Exchange, ExchangePanel> exchangeToPanel = new HashMap<>();
    private static JFrame frame;
    private static JTextField searchField;
    private static List<Conversation> allConversations = new ArrayList<>();
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        frame = new JFrame("Colog V3");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);
        frame.setResizable(true);

        JMenuBar menuBar = new JMenuBar();
        JMenu fileMenu = new JMenu("File");

        JMenuItem openItem = new JMenuItem("Open");
        openItem.addActionListener(e -> handleOpen(frame));
        fileMenu.add(openItem);

        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);

        menuBar.add(fileMenu);
        frame.setJMenuBar(menuBar);

        container = new JPanel();
        container.setLayout(new BoxLayout(container, BoxLayout.Y_AXIS));

        scrollPane = new JScrollPane(container);

        summaryPanel = new JPanel();
        summaryPanel.setLayout(new BoxLayout(summaryPanel, BoxLayout.Y_AXIS));

        JPanel searchPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        searchPanel.add(new JLabel("Search: "));
        searchField = new JTextField(40);
        searchPanel.add(searchField);
        JButton clearFilter = new JButton("Clear Tag Filter");
        clearFilter.addActionListener(e -> TagFilter.clear());
        searchPanel.add(clearFilter);
        searchField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) { applySearchAndTagFilter(); }

            @Override
            public void removeUpdate(DocumentEvent e) { applySearchAndTagFilter(); }

            @Override
            public void changedUpdate(DocumentEvent e) { applySearchAndTagFilter(); }
        });

        JPanel rootPanel = new JPanel(new BorderLayout());
        rootPanel.add(searchPanel, BorderLayout.NORTH);

        JSplitPane splitPane = new JSplitPane(
                JSplitPane.HORIZONTAL_SPLIT,
                summaryPanel,
                scrollPane
        );
        splitPane.setDividerLocation(300);
        rootPanel.add(splitPane, BorderLayout.CENTER);

        frame.setContentPane(rootPanel);

        TagFilter.setFilterListener(() -> applySearchAndTagFilter());

        frame.setVisible(true);
    }

    private static void handleOpen(JFrame parent) {
        JFileChooser chooser = new JFileChooser(lastDir);
        FileNameExtensionFilter filter = new FileNameExtensionFilter("JSON files", "json");
        chooser.setFileFilter(filter);
        int result = chooser.showOpenDialog(parent);
        if (result == JFileChooser.APPROVE_OPTION) {
            File selected = chooser.getSelectedFile();
            lastDir = selected.getParentFile();
            if (!selected.getName().toLowerCase().endsWith(".json")) {
                JOptionPane.showMessageDialog(parent, "Please select a .json file.",
                        "Invalid File", JOptionPane.ERROR_MESSAGE);
                return;
            }
            try {
                allConversations = ConversationLoader.parseConversationsFromFile(selected);
                applySearchAndTagFilter();
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(parent, "Error reading file: " + ex.getMessage(),
                        "Read Error", JOptionPane.ERROR_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(parent, "Failed to parse JSON: " + ex.getMessage(),
                        "Parse Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private static void applySearchAndTagFilter() {
        if (scrollPane == null) return;
        String query = searchField.getText().toLowerCase();

        JScrollBar bar = scrollPane.getVerticalScrollBar();
        int val = bar.getValue();

        container.removeAll();
        summaryPanel.removeAll();
        exchangeToPanel.clear();

        for (Conversation c : allConversations) {
            List<Exchange> matches = new ArrayList<>();
            for (Exchange ex : c.exchanges) {
                if (TagFilter.matches(ex) && matchesSearchQuery(ex, query)) {
                    matches.add(ex);
                }
            }
            if (!matches.isEmpty()) {
                ConversationPanel cp = new ConversationPanel(c.title, matches);
                container.add(cp);

                java.util.List<ExchangePanel> eps = cp.getExchangePanels();
                for (int i = 0; i < matches.size(); i++) {
                    Exchange ex = matches.get(i);
                    ExchangePanel ep = eps.get(i);
                    exchangeToPanel.put(ex, ep);

                    JButton btn = new JButton(ex.summary);
                    btn.setToolTipText(c.title);
                    btn.setHorizontalAlignment(SwingConstants.LEFT);
                    btn.setMaximumSize(new Dimension(Integer.MAX_VALUE, btn.getPreferredSize().height));
                    btn.addActionListener(e -> ep.expandAndFocus());
                    summaryPanel.add(btn);
                }
            }
        }
        container.revalidate();
        container.repaint();
        summaryPanel.revalidate();
        summaryPanel.repaint();
        scrollPane.revalidate();
        bar.setValue(val);
    }

    private static boolean matchesSearchQuery(Exchange ex, String query) {
        if (query.isBlank()) return true;
        String tags = String.join(" ", ex.tags).toLowerCase();
        return (ex.prompt != null && ex.prompt.toLowerCase().contains(query)) ||
               (ex.response != null && ex.response.toLowerCase().contains(query)) ||
               (ex.summary != null && ex.summary.toLowerCase().contains(query)) ||
               tags.contains(query);
    }
}
