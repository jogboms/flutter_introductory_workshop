// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type {NextApiRequest, NextApiResponse} from 'next'
import fs from 'fs';
import path from 'path';

type ErrorData = {
    error: boolean;
    message: string;
}

export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<ErrorData>
) {
    try {
        const id = req.query.id;
        const filePath = path.join(process.cwd(), `/public/images/${id}.png`);
        const imageBuffer = fs.createReadStream(filePath);

        await new Promise(function (resolve) {
            res.setHeader('Content-Type', 'image/png');
            imageBuffer.pipe(res);
            imageBuffer.on('end', resolve);
            imageBuffer.on('error', function (err) {
                if ((err as any).code === 'ENOENT') {
                    res.status(400).json({
                        error: true,
                        message: 'File could not be found'
                    });
                } else {
                    res
                        .status(500)
                        .json({error: true, message: 'Something went wrong!'});
                }
                res.end();
            });
        });
    } catch (err) {
        res.status(400).json({error: true, message: `${err}`});
        res.end();
    }
}
