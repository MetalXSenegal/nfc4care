package com.nfc4care.service;

import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
import com.nfc4care.entity.DossierMedical;
import com.nfc4care.entity.Patient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.format.DateTimeFormatter;

/**
 * Service pour l'export de dossiers médicaux en PDF et Excel
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class ExportService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    /**
     * Génère un export PDF du dossier médical d'un patient
     */
    public ByteArrayOutputStream exportToPDF(Patient patient, DossierMedical dossier) throws DocumentException, IOException {
        log.info("Génération du PDF pour le patient: {}", patient.getNumeroDossier());

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        Document document = new Document(PageSize.A4, 50, 50, 50, 50);
        PdfWriter.getInstance(document, outputStream);
        document.open();

        // En-tête
        Font titleFont = new Font(Font.FontFamily.HELVETICA, 18, Font.BOLD);
        Paragraph title = new Paragraph("DOSSIER MÉDICAL PATIENT", titleFont);
        title.setAlignment(Element.ALIGN_CENTER);
        document.add(title);
        document.add(new Paragraph(" "));

        // Informations patient
        Font sectionFont = new Font(Font.FontFamily.HELVETICA, 14, Font.BOLD);
        document.add(new Paragraph("INFORMATIONS PATIENT", sectionFont));

        PdfPTable patientTable = new PdfPTable(2);
        patientTable.setWidthPercentage(100);
        addTableRow(patientTable, "Numéro de dossier:", patient.getNumeroDossier());
        addTableRow(patientTable, "Nom:", patient.getNom());
        addTableRow(patientTable, "Prénom:", patient.getPrenom());
        addTableRow(patientTable, "Date de naissance:", patient.getDateNaissance().format(DATE_FORMATTER));
        addTableRow(patientTable, "Sexe:", patient.getSexe());
        addTableRow(patientTable, "Groupe sanguin:", patient.getGroupeSanguin());
        addTableRow(patientTable, "Téléphone:", patient.getTelephone());
        addTableRow(patientTable, "Email:", patient.getEmail());
        addTableRow(patientTable, "Numéro Sécurité Sociale:", patient.getNumeroSecuriteSociale());
        document.add(patientTable);
        document.add(new Paragraph(" "));

        // Dossier médical
        if (dossier != null) {
            document.add(new Paragraph("DOSSIER MÉDICAL", sectionFont));

            addTableRow(document, "Antécédents médicaux:", dossier.getAntecedentsMedicaux());
            addTableRow(document, "Antécédents chirurgicaux:", dossier.getAntecedentsChirurgicaux());
            addTableRow(document, "Antécédents familiaux:", dossier.getAntecedentsFamiliaux());
            addTableRow(document, "Traitements en cours:", dossier.getTraitementsEnCours());
            addTableRow(document, "Allergies:", dossier.getAllergies());
            addTableRow(document, "Observations:", dossier.getObservationsGenerales());
        }

        document.close();
        log.info("PDF généré avec succès pour le patient: {}", patient.getNumeroDossier());
        return outputStream;
    }

    /**
     * Génère un export Excel du dossier médical d'un patient
     */
    public ByteArrayOutputStream exportToExcel(Patient patient, DossierMedical dossier) throws IOException {
        log.info("Génération du Excel pour le patient: {}", patient.getNumeroDossier());

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        Workbook workbook = new XSSFWorkbook();
        Sheet sheet = workbook.createSheet("Dossier Médical");

        // Style en-tête
        CellStyle headerStyle = createHeaderStyle(workbook);

        // En-tête
        Row headerRow = sheet.createRow(0);
        Cell cell = headerRow.createCell(0);
        cell.setCellValue("DOSSIER MÉDICAL - " + patient.getNumeroDossier());
        cell.setCellStyle(headerStyle);
        sheet.addMergedRegion(new org.apache.poi.ss.util.CellRangeAddress(0, 0, 0, 3));

        // Informations patient
        int rowNum = 2;
        addExcelRow(sheet, rowNum++, "Numéro de dossier:", patient.getNumeroDossier(), headerStyle);
        addExcelRow(sheet, rowNum++, "Nom:", patient.getNom(), headerStyle);
        addExcelRow(sheet, rowNum++, "Prénom:", patient.getPrenom(), headerStyle);
        addExcelRow(sheet, rowNum++, "Date de naissance:", patient.getDateNaissance().format(DATE_FORMATTER), headerStyle);
        addExcelRow(sheet, rowNum++, "Sexe:", patient.getSexe(), headerStyle);
        addExcelRow(sheet, rowNum++, "Groupe sanguin:", patient.getGroupeSanguin(), headerStyle);
        addExcelRow(sheet, rowNum++, "Téléphone:", patient.getTelephone(), headerStyle);
        addExcelRow(sheet, rowNum++, "Email:", patient.getEmail(), headerStyle);
        addExcelRow(sheet, rowNum++, "Numéro SS:", patient.getNumeroSecuriteSociale(), headerStyle);

        rowNum += 2;

        // Dossier médical
        if (dossier != null) {
            Row dossierHeaderRow = sheet.createRow(rowNum++);
            Cell dossierHeader = dossierHeaderRow.createCell(0);
            dossierHeader.setCellValue("DOSSIER MÉDICAL");
            dossierHeader.setCellStyle(headerStyle);

            rowNum++; // Espace
            addExcelRow(sheet, rowNum++, "Antécédents médicaux:", dossier.getAntecedentsMedicaux(), headerStyle);
            addExcelRow(sheet, rowNum++, "Antécédents chirurgicaux:", dossier.getAntecedentsChirurgicaux(), headerStyle);
            addExcelRow(sheet, rowNum++, "Antécédents familiaux:", dossier.getAntecedentsFamiliaux(), headerStyle);
            addExcelRow(sheet, rowNum++, "Traitements en cours:", dossier.getTraitementsEnCours(), headerStyle);
            addExcelRow(sheet, rowNum++, "Allergies:", dossier.getAllergies(), headerStyle);
            addExcelRow(sheet, rowNum++, "Observations:", dossier.getObservationsGenerales(), headerStyle);
        }

        // Auto-ajuster les colonnes
        sheet.autoSizeColumn(0);
        sheet.autoSizeColumn(1);

        workbook.write(outputStream);
        workbook.close();
        log.info("Excel généré avec succès pour le patient: {}", patient.getNumeroDossier());
        return outputStream;
    }

    private void addTableRow(PdfPTable table, String label, String value) {
        Font boldFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD);
        PdfPCell labelCell = new PdfPCell(new Phrase(label, boldFont));
        labelCell.setBackgroundColor(BaseColor.LIGHT_GRAY);
        table.addCell(labelCell);
        table.addCell(new PdfPCell(new Phrase(value != null ? value : "-")));
    }

    private void addTableRow(Document document, String label, String value) throws DocumentException {
        Font boldFont = new Font(Font.FontFamily.HELVETICA, 10, Font.BOLD);
        Paragraph p = new Paragraph();
        p.add(new Chunk(label, boldFont));
        p.add(new Chunk(" " + (value != null ? value : "-")));
        document.add(p);
    }

    private CellStyle createHeaderStyle(Workbook workbook) {
        CellStyle style = workbook.createCellStyle();
        org.apache.poi.ss.usermodel.Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.LIGHT_BLUE.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        return style;
    }

    private void addExcelRow(Sheet sheet, int rowNum, String label, String value, CellStyle headerStyle) {
        Row row = sheet.createRow(rowNum);
        Cell labelCell = row.createCell(0);
        labelCell.setCellValue(label);
        labelCell.setCellStyle(headerStyle);

        Cell valueCell = row.createCell(1);
        valueCell.setCellValue(value != null ? value : "-");
    }
}
