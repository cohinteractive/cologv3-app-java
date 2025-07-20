package colog;

import javax.swing.*;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;
import javax.swing.filechooser.FileNameExtensionFilter;

import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;

import colog.TagFilter;
import colog.ConversationRowPanel;
import static colog.Theme.*;
import static colog.UIStyle.*;


public class Main {
    private static File lastDir;
    private static JPanel container;
    private static JScrollPane scrollPane;
    private static JPanel conversationListPanel;
    private static JScrollPane conversationScrollPane;
    private static JSplitPane splitPane;
    private static java.util.List<ConversationRowPanel> conversationRows = new ArrayList<>();
    private static java.util.List<Conversation> visibleConversations = new ArrayList<>();
    private static int selectedConversationIndex = -1;
    private static JFrame frame;
    private static JTextField searchField;
    private static JLabel tagFilterStatus;
    private static JButton clearFilter;
    private static List<Conversation> allConversations = new ArrayList<>();
    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> createAndShowGUI());
    }

    private static void createAndShowGUI() {
        frame = new JFrame("Colog V3");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(800, 600);
        frame.setResizable(true);
        frame.getContentPane().setBackground(DARK_BG);

        JMenuBar menuBar = new JMenuBar();
        menuBar.setBackground(DARK_BG);
        menuBar.setForeground(LIGHT_TEXT);
        menuBar.setFont(BASE_FONT);
        JMenu fileMenu = new JMenu("File");
        fileMenu.setBackground(DARK_BG);
        fileMenu.setForeground(LIGHT_TEXT);
        fileMenu.setFont(BASE_FONT);

        JMenuItem openItem = new JMenuItem("Open");
        openItem.addActionListener(e -> handleOpen(frame));
        openItem.setBackground(DARK_BG);
        openItem.setForeground(LIGHT_TEXT);
        openItem.setFont(BASE_FONT);
        fileMenu.add(openItem);

        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        exitItem.setBackground(DARK_BG);
        exitItem.setForeground(LIGHT_TEXT);
        exitItem.setFont(BASE_FONT);
        fileMenu.add(exitItem);

        menuBar.add(fileMenu);
        frame.setJMenuBar(menuBar);

        container = new JPanel();
        container.setLayout(new BoxLayout(container, BoxLayout.Y_AXIS));
        container.setBackground(DARK_BG);

        scrollPane = new JScrollPane(container);
        scrollPane.getVerticalScrollBar().setUnitIncrement(24);
        scrollPane.setBorder(BorderFactory.createEmptyBorder());
        scrollPane.getViewport().setBackground(DARK_BG);

        conversationListPanel = new JPanel();
        conversationListPanel.setLayout(new BoxLayout(conversationListPanel, BoxLayout.Y_AXIS));
        conversationListPanel.setBackground(DARK_BG);
        conversationScrollPane = new JScrollPane(conversationListPanel);
        conversationScrollPane.getVerticalScrollBar().setUnitIncrement(24);
        conversationScrollPane.setBorder(BorderFactory.createEmptyBorder());
        conversationScrollPane.setHorizontalScrollBarPolicy(ScrollPaneConstants.HORIZONTAL_SCROLLBAR_NEVER);
        conversationScrollPane.getViewport().setBackground(DARK_BG);

        JPanel searchPanel = new JPanel(new FlowLayout(FlowLayout.LEFT));
        searchPanel.setBackground(DARK_BG);
        JLabel searchLabel = new JLabel("Search prompt/response:");
        searchLabel.setForeground(LIGHT_TEXT);
        searchLabel.setFont(BASE_FONT);
        searchPanel.add(searchLabel);
        searchField = new JTextField(40);
        searchField.setBackground(DARK_BG);
        searchField.setForeground(LIGHT_TEXT);
        searchField.setCaretColor(LIGHT_TEXT);
        searchField.setFont(BASE_FONT);
        searchPanel.add(searchField);
        tagFilterStatus = new JLabel();
        tagFilterStatus.setForeground(LIGHT_TEXT);
        tagFilterStatus.setFont(BASE_FONT);
        searchPanel.add(tagFilterStatus);
        clearFilter = new JButton("Clear Tag Filter");
        clearFilter.addActionListener(e -> TagFilter.clear());
        clearFilter.setBackground(DARK_BG);
        clearFilter.setForeground(LIGHT_TEXT);
        clearFilter.setFont(BASE_FONT);
        searchPanel.add(clearFilter);
        clearFilter.setEnabled(false);
        searchField.getDocument().addDocumentListener(new DocumentListener() {
            @Override
            public void insertUpdate(DocumentEvent e) { applySearchAndTagFilter(); }

            @Override
            public void removeUpdate(DocumentEvent e) { applySearchAndTagFilter(); }

            @Override
            public void changedUpdate(DocumentEvent e) { applySearchAndTagFilter(); }
        });

        frame.setLayout(new BorderLayout());
        frame.add(searchPanel, BorderLayout.NORTH);

        splitPane = new JSplitPane(
                JSplitPane.HORIZONTAL_SPLIT,
                conversationScrollPane,
                scrollPane
        );
        splitPane.setBackground(DARK_BG);
        splitPane.setDividerLocation(300);
        frame.add(splitPane, BorderLayout.CENTER);

        TagFilter.setFilterListener(() -> {
            updateTagFilterLabel();
            applySearchAndTagFilter();
        });
        updateTagFilterLabel();

        frame.addComponentListener(new ComponentAdapter() {
            @Override
            public void componentResized(ComponentEvent e) {
                splitPane.setDividerLocation(0.3);
            }
        });

        frame.pack();
        frame.setSize(800, 600);
        frame.setLocationRelativeTo(null);
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
                List<Conversation> conversations = ConversationLoader.parseConversationsFromFile(selected);

                // Store parsed conversations so search/tag filters work
                allConversations = conversations;

                conversationRows.clear();
                conversationListPanel.removeAll();
                container.removeAll();
                visibleConversations = conversations;
                buildConversationList();
                if (!visibleConversations.isEmpty()) {
                    selectConversation(0);
                }
                conversationListPanel.revalidate();
                container.revalidate();
                splitPane.setEnabled(true);
                splitPane.setDividerLocation(300);
                splitPane.revalidate();

                System.out.println("[INFO] Loaded " + conversations.size() + " conversation(s).");
            } catch (IOException ex) {
                JOptionPane.showMessageDialog(parent, "Error reading file: " + ex.getMessage(),
                        "Read Error", JOptionPane.ERROR_MESSAGE);
            } catch (Exception ex) {
                JOptionPane.showMessageDialog(parent, "Failed to parse JSON: " + ex.getMessage(),
                        "Parse Error", JOptionPane.ERROR_MESSAGE);
            }
            frame.pack();
        }
    }

    private static void applySearchAndTagFilter() {
        if (scrollPane == null) return;
        String query = searchField.getText().toLowerCase();

        JScrollBar bar = scrollPane.getVerticalScrollBar();
        int val = bar.getValue();

        container.removeAll();
        conversationListPanel.removeAll();
        conversationRows.clear();

        List<Conversation> matches;
        if (query.isEmpty() && TagFilter.getActiveTag() == null) {
            matches = allConversations;
        } else {
            matches = allConversations.stream()
                    .map(c -> {
                        Conversation nc = new Conversation(c.title);
                        for (Exchange ex : c.exchanges) {
                            if (matchesSearchQuery(ex, query) && TagFilter.matches(ex)) {
                                nc.exchanges.add(ex);
                            }
                        }
                        return nc;
                    })
                    .filter(c -> !c.exchanges.isEmpty())
                    .collect(java.util.stream.Collectors.toList());
        }
        visibleConversations = matches;
        buildConversationList();
        if (!visibleConversations.isEmpty()) {
            selectConversation(Math.min(selectedConversationIndex, visibleConversations.size() - 1));
        } else {
            selectedConversationIndex = -1;
            container.revalidate();
            container.repaint();
        }
        conversationListPanel.revalidate();
        scrollPane.revalidate();
        if (splitPane != null) splitPane.revalidate();
        bar.setValue(val);
    }

    private static void buildConversationList() {
        conversationListPanel.removeAll();
        conversationRows.clear();
        conversationListPanel.add(new ConversationHeaderRowPanel());
        for (int i = 0; i < visibleConversations.size(); i++) {
            Conversation c = visibleConversations.get(i);
            ConversationRowPanel row = new ConversationRowPanel(i + 1, c);
            conversationRows.add(row);
            conversationListPanel.add(row);
        }
    }

    private static void selectConversation(int index) {
        if (index < 0 || index >= visibleConversations.size()) return;
        selectConversation(visibleConversations.get(index));
    }

    public static void selectConversation(Conversation c) {
        if (c == null) return;
        selectedConversationIndex = visibleConversations.indexOf(c);
        container.removeAll();
        container.add(new ConversationPanel(c));
        container.revalidate();
        container.repaint();
        for (int i = 0; i < conversationRows.size(); i++) {
            conversationRows.get(i).setSelected(visibleConversations.get(i) == c);
        }
    }

    private static void updateTagFilterLabel() {
        if (tagFilterStatus == null || clearFilter == null) return;
        String tag = TagFilter.getActiveTag();
        if (tag != null) {
            tagFilterStatus.setText("Filtering by tag: #" + tag);
            tagFilterStatus.setForeground(LIGHT_TEXT);
            clearFilter.setEnabled(true);
        } else {
            tagFilterStatus.setText("");
            clearFilter.setEnabled(false);
        }
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
